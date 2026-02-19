extends Node

@export var map: PackedScene = preload("res://Scenes/Maps/training_floor.tscn")

var player_one_fighter: Fighter = null
var player_two_fighter: Fighter = null

func character_chosen(player_id: int, fighter: Fighter):
	if player_id == 1:
		player_one_fighter = fighter
	elif player_id == 2:
		player_two_fighter = fighter

func get_fighters() -> Array[Fighter]:
	var result: Array[Fighter] = []
	
	if player_one_fighter:
		result.append(player_one_fighter)
	if player_two_fighter:
		result.append(player_two_fighter)
	
	return result
	
func start_game():
	change_map()
	add_players()
	
func add_players():
	add_child(player_one_fighter, true)
	player_one_fighter.global_position = Vector2(64, 136)
	player_one_fighter.player_number = 1
	
	add_child(player_two_fighter, true)
	player_two_fighter.global_position = Vector2(320, 136)
	player_two_fighter.player_number = 2
	
func change_map():
	get_tree().change_scene_to_file(map.resource_path)
	
