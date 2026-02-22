extends Camera2D
class_name DynamicCamera

var cameraShakeNoise: FastNoiseLite

# --- Stage bounds (match your map's wall positions) ---
@export var stage_left: float = 12.0
@export var stage_right: float = 372.0

# --- Camera settings ---
@export var camera_speed: float = 6.0
@export var zoom_level: float = 1.0      # Fixed zoom, no dynamic scaling

var fighters: Array[Fighter] = []

# Half the viewport width in world units (at zoom 1.0, this is 192)
var half_view: Vector2 = Vector2(160, 108)
var fight_over: bool = false

func _ready():
	cameraShakeNoise = FastNoiseLite.new()
	zoom = Vector2(zoom_level, zoom_level)
	half_view = get_viewport_rect().size / 2.0
	global_position = half_view
	
func _process(delta: float) -> void:
	if fight_over:
		return
	_update_camera(delta)
	_push_players_with_camera()

func _update_camera(delta: float) -> void:
	if fighters.is_empty():
		fighters = Global.get_fighters()  # assign directly, not append
		for fighter in fighters:
			fighter.died.connect(_on_player_died)
	
	# Filter out dead/freed fighters before using them
	fighters = fighters.filter(func(f): return is_instance_valid(f))
	
	if fighters.size() < 2:
		return

	var pos_a: Vector2 = fighters[0].global_position
	var pos_b: Vector2 = fighters[1].global_position
	var mid_x := (pos_a.x + pos_b.x) / 2.0
	var mid_y := (pos_a.y + pos_b.y - 32) / 2.0
	var clamped_x := clampf(mid_x, stage_left + half_view.x, stage_right - half_view.x)
	var clamped_y := clampf(mid_y, half_view.y - 16.0, half_view.y)
	var target := Vector2(clamped_x, clamped_y)
	global_position = global_position.lerp(target, camera_speed * delta)

func _push_players_with_camera() -> void:
	if fighters.is_empty():
		return
	var cam_left := global_position.x - half_view.x
	var cam_right := global_position.x + half_view.x
	for fighter in fighters:
		if not is_instance_valid(fighter):
			continue
		var inset := 10.0
		fighter.global_position.x = clampf(
			fighter.global_position.x,
			cam_left + inset,
			cam_right - inset
		)

func _on_player_died():
	fight_over = true
		
func cam_shake(Max: float, Min: float, Length: float):
	var camera_tween = get_tree().create_tween()
	camera_tween.tween_method(StartCameraShake, Max, Min, Length)

func StartCameraShake(intensity: float):
	var cameraOffset = cameraShakeNoise.get_noise_1d(Time.get_ticks_msec()) * intensity
	offset.x = cameraOffset
	offset.y = cameraOffset
