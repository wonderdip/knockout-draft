extends TextureProgressBar
class_name GradientHealthBar

@export var transition_speed: float = 150
@export var health_gradient: GradientTexture2D
@export var player: Player = null

var is_flashing := false

func _ready() -> void:
	player.health_changed.connect(_on_health_changed)
	# Initialize with current health
	max_value = player.max_health
	value = player.current_health
	update_gradient_colors(1)
	
func _process(delta: float) -> void:
	value = move_toward(value, player.current_health, transition_speed * delta)
	if value/max_value <= 0.3 and not is_flashing:
		flash_gradient()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hurt"):
		player.take_damage(get_tree().get_first_node_in_group("PunchingBag"), HitEffects.HitStrength.MEDIUM)

func _on_health_changed(current: float, maximum: float) -> void:
	max_value = maximum
	update_gradient_colors(current / maximum)

func flash_gradient():
	is_flashing = true
	
	var grad_texture = texture_progress as GradientTexture2D
	var gradient = grad_texture.gradient
	
	for i in 6:
		gradient.set_color(0, Color.WHITE)
		gradient.set_color(1, Color.WHITE)
		await get_tree().create_timer(0.4).timeout
		
		update_gradient_colors(value / max_value)
		await get_tree().create_timer(0.4).timeout
	
	is_flashing = false	

## Updates gradient colors based on health percentage
func update_gradient_colors(percent: float) -> void:
	var grad_texture := texture_progress as GradientTexture2D
	var gradient := grad_texture.gradient
	
	var col := health_gradient.gradient.sample(percent)
	var col2 := health_gradient.gradient.sample(percent - 0.2)
	
	gradient.set_color(0, col)
	gradient.set_color(1, col2)
	
	if percent <= 0.60:
		player.mug_shot.frame = 1
	if percent <= 0.25:
		player.mug_shot.frame = 2
		
