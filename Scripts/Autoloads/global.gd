extends Node

@export var map: PackedScene = preload("res://Scenes/Maps/training_floor.tscn")

var player_one_fighter: Fighter = null
var player_two_fighter: Fighter = null
var game_started: bool = false

func character_chosen(player_id: int, fighter: Fighter):
	if player_id == 1:
		player_one_fighter = fighter
		player_one_fighter.player_number = player_id
		player_one_fighter.device_id = 0
	elif player_id == 2:
		player_two_fighter = fighter
		player_two_fighter.player_number = player_id
		player_two_fighter.device_id = 1

func get_fighters() -> Array[Fighter]:
	var result: Array[Fighter] = []
	
	if player_one_fighter:
		result.append(player_one_fighter)
	if player_two_fighter:
		result.append(player_two_fighter)
	
	return result

func _process(delta: float) -> void:
	if player_one_fighter and player_two_fighter:
		if player_one_fighter.is_inside_tree() and player_two_fighter.is_inside_tree():
			var player_distance: float = player_one_fighter.global_position.x - player_two_fighter.global_position.x
			if player_distance > 0:
				player_one_fighter.change_direction(-1)
				player_two_fighter.change_direction(1)
			else:
				player_one_fighter.change_direction(1)
				player_two_fighter.change_direction(-1)
	pass
func start_game():
	game_started = true
	change_map()
	add_players()
	
func add_players():
	add_child(player_one_fighter, true)
	player_one_fighter.global_position = Vector2(64 + 50, 136)
	player_one_fighter.other_fighter = player_two_fighter
	add_child(player_two_fighter, true)
	player_two_fighter.global_position = Vector2(320-50, 136)
	player_two_fighter.other_fighter = player_one_fighter
	
func change_map():

	get_tree().change_scene_to_file(map.resource_path)
	
