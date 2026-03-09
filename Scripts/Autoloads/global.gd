extends Node

var player_one_fighter: Fighter = null
var player_two_fighter: Fighter = null
var p1_victories: int
var p2_victories: int
var round_loser: int

var rounds: int = 0
var game_started: bool = false
var current_map: String

func character_chosen(player_id: int, fighter: Fighter):
	if player_id == 1:
		player_one_fighter = fighter
		player_one_fighter.player_number = player_id
		player_one_fighter.device_id = 0
	elif player_id == 2:
		player_two_fighter = fighter
		player_two_fighter.player_number = player_id
		player_two_fighter.device_id = 1

func get_fighter(player_number: int) -> Fighter:
	if player_number == 1:
		return player_one_fighter
	elif player_number == 2:
		return player_two_fighter
	return null
	
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
	
func start_game():
	if game_started:
		refresh_players()
		return
	else:
		game_started = true
		add_players()

func upgrade_chosen(player_number: int, upgrade_data: UpgradeData):
	upgrade_data.apply_upgrade(get_fighter(player_number))
	SceneManager.change_scene(SceneManager.get_map(current_map), true)
	
func _on_round_over(player_number: int):
	for player in get_fighters():
		player.hide()
		player.ui_layer.hide()
	match player_number:
		2:
			p1_victories += 1
			round_loser = 2
		1:
			p2_victories += 1
			round_loser = 1
			
	SceneManager.change_scene(SceneManager.get_menu("UpgradePicker"), false)
	print("Player One Victories: ", p1_victories, " Player Two Victories: ", p2_victories)
	
func refresh_players():
	rounds += 1
	for player in get_fighters():
		player.state_machine.change_state(player.state_machine.states.get("Walk"))
		player.stamina = player.max_stamina
		player.heal(player.max_health)
		player.mug_shot.frame = 0
		player.animation_player.play("RESET")
		player.show()
		player.ui_layer.show()
	player_one_fighter.position = Vector2(70, 150)
	player_two_fighter.position = Vector2(250, 150)
	
func add_players():
	add_child(player_one_fighter, true)
	add_child(player_two_fighter, true)
	
	player_one_fighter.other_fighter = player_two_fighter
	player_two_fighter.other_fighter = player_one_fighter
	player_one_fighter.died.connect(_on_round_over)
	player_two_fighter.died.connect(_on_round_over)
	
	await get_tree().process_frame
	
	player_one_fighter.position = Vector2(70, 150)
	player_two_fighter.position = Vector2(250, 150)
	
