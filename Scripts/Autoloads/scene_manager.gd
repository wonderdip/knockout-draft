extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var maps: Array[MapResource]
@export var menus: Array[MenuResource]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.hide()

func get_map(map_name: String) -> PackedScene:
	for map in maps:
		if map.name == map_name:
			return map.map_scene
	push_error("Map not found: " + map_name)
	return null

func get_menu(menu_name: String) -> PackedScene:
	for menu in menus:
		if menu.name == menu_name:
			return menu.menu_scene
	push_error("Menu not found: " + menu_name)
	return null
	
func change_scene(scene: PackedScene, game_start: bool):
	color_rect.show()
	animation_player.play("exit")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(scene)
	
	if game_start:
		Global.start_game()
		
	animation_player.play("enter")
