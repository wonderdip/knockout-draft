extends Control

@export var first_button: CharacterSelectorbutton
var buttons: Array[CharacterSelectorbutton]
var player_devices := {}
var p1_index := 0
var p2_index := 1

@onready var p1_outline: Sprite2D = $P1Outline
@onready var p2_outline: Sprite2D = $P2Outline
@onready var start: Button = $Start

var p1_chosen_button: CharacterSelectorbutton = null
var p2_chosen_button: CharacterSelectorbutton = null

var p1_hold_timer := 0.0
var p2_hold_timer := 0.0

var hold_delay := 0.3       # Time before repeat starts (first delay)
var repeat_rate := 0.15      # Time between repeats after delay
var p1_axis_direction := 0   # -1 = left, 1 = right, 0 = neutral
var p2_axis_direction := 0
var analog_deadzone := 0.5
var can_start: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p1_outline.modulate = Color.BLUE
	p2_outline.modulate = Color.RED
	assign_devices()
	if buttons.is_empty():
		collect_buttons(self)
		
	# Now buttons are ready
	p1_index = 0
	p2_index = min(1, buttons.size() - 1) # avoids out-of-bounds
	p1_outline.global_position = buttons[p1_index].global_position + Vector2(19, 54)
	p2_outline.global_position = buttons[p2_index].global_position + Vector2(57, 54)
	
func assign_devices():
	var pads = Input.get_connected_joypads()
	print(pads)
	
	if pads.size() >= 1:
		player_devices[1] = pads[0]
		p1_outline.show()
		if pads.size() >= 2:
			p2_outline.show()
			player_devices[2] = pads[1]
			
func _unhandled_input(event):
	if event is InputEvent:
		var player_id := 0
		if event.device == player_devices.get(1):
			player_id = 1
		elif event.device == player_devices.get(2):
			player_id = 2
			
			
		if event.is_action_pressed("ui_escape"):
			start.release_focus()
			can_start = false
			
		if player_id == 0 or can_start:
			return
			
		if event.is_action_pressed("select"):
			if player_id == 1:
				if p1_chosen_button:
					p1_chosen_button.unchoose()
				
				p1_chosen_button = buttons[p1_index]
				p1_chosen_button.choose(1)
			else:
				if p2_chosen_button:
					p2_chosen_button.unchoose()
				
				p2_chosen_button = buttons[p2_index]
				p2_chosen_button.choose(2)
			update_start_state()
				
		if event.is_action_pressed("ui_right"):
			if player_id == 1:
				p1_index = clamp(p1_index + 1, 0, buttons.size() - 1)
			else:
				p2_index = clamp(p2_index + 1, 0, buttons.size() - 1)
			update_outlines()

		if event.is_action_pressed("ui_left"):
			if player_id == 1:
				p1_index = clamp(p1_index - 1, 0, buttons.size() - 1)
			else:
				p2_index = clamp(p2_index - 1, 0, buttons.size() - 1)
			update_outlines()
			
func _handle_analog(_index: int, axis_dir: int, hold_timer: float, player_id: int, delta: float):
	var device = player_devices.get(player_id)
	if device == null or can_start:
		return

	# Get horizontal axis
	var value = Input.get_joy_axis(device, JOY_AXIS_LEFT_X)

	var dir := 0
	if value > analog_deadzone:
		dir = 1
	elif value < -analog_deadzone:
		dir = -1

	# Stick neutral
	if dir == 0:
		if player_id == 1:
			p1_hold_timer = 0
			p1_axis_direction = 0
		else:
			p2_hold_timer = 0
			p2_axis_direction = 0
		return

	# First tilt
	if dir != axis_dir:
		# Move once immediately
		_move_player(player_id, dir)
		if player_id == 1:
			p1_hold_timer = 0
			p1_axis_direction = dir
		else:
			p2_hold_timer = 0
			p2_axis_direction = dir
		return

	# Holding in the same direction
	hold_timer += delta

	if hold_timer > hold_delay:
		# How many repeats have passed
		if int((hold_timer - hold_delay) / repeat_rate) > int((hold_timer - hold_delay - delta) / repeat_rate):
			_move_player(player_id, dir)

	# Update timers
	if player_id == 1:
		p1_hold_timer = hold_timer
	else:
		p2_hold_timer = hold_timer
		
func _move_player(player_id: int, dir: int):
	if player_id == 1:
		p1_index = clamp(p1_index + dir, 0, buttons.size() - 1)
	else:
		p2_index = clamp(p2_index + dir, 0, buttons.size() - 1)
	update_outlines()

func _process(delta):
	if Input.joy_connection_changed and Input.get_connected_joypads().size() < 2:
		assign_devices()
		
	_handle_analog(p1_index, p1_axis_direction, p1_hold_timer, 1, delta)
	_handle_analog(p2_index, p2_axis_direction, p2_hold_timer, 2, delta)

func update_start_state():
	if p1_chosen_button != null and p2_chosen_button != null:
		start.grab_focus()
		can_start = true
	else:
		start.release_focus()
		can_start = false

func update_outlines():
	p1_outline.global_position = buttons[p1_index].global_position + Vector2(19, 27)
	p2_outline.global_position = buttons[p2_index].global_position + Vector2(19, 27)

func collect_buttons(node: Variant):
	for button in node.get_children():
		if button is CharacterSelectorbutton:
			buttons.append(button)
			button.character_chosen.connect(_on_character_chosen)
		collect_buttons(button)
	
func _on_character_chosen(player_id: int, fighter: Fighter):
	Global.character_chosen(player_id, fighter)
	
func _on_start_pressed() -> void:
	if can_start:
		Global.start_game()
