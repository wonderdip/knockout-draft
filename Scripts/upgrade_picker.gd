extends Control

var buttons: Array[UpgradeButton]
var player_devices := {}
var current_index := 0

var player_number: int = 2 

@onready var outline: Sprite2D = $Outline
@onready var confirm_button: Button = $ConfirmButton

var chosen_button: UpgradeButton = null

var hold_timer := 0.0
var axis_direction := 0

var hold_delay := 0.3       # Time before repeat starts (first delay)
var repeat_rate := 0.15      # Time between repeats after delay
var analog_deadzone := 0.5
var can_start: bool = false

func _ready() -> void:
	match player_number:
		1:
			outline.modulate = Color.BLUE
		2:
			outline.modulate = Color.RED
	
	assign_devices()
	
	if buttons.is_empty():
		collect_buttons(self)
		
	current_index = int((buttons.size() - 1) / 2)
	
func assign_devices():
	var pads = Input.get_connected_joypads()
	
	if pads.size() >= 1:
		player_devices[1] = pads[0]
		if pads.size() >= 2:
			player_devices[2] = pads[1]
	
func _unhandled_input(event):
	if event is InputEvent:
		var player_id := 0
		if event.device == player_devices.get(1):
			player_id = 1
		elif event.device == player_devices.get(2):
			player_id = 2
			
		if player_id != player_number:
			return
			
		if event.is_action_pressed("ui_escape"):
			if can_start:
				confirm_button.release_focus()
				can_start = false
				
				if chosen_button:
					chosen_button.unchoose()
					chosen_button = null
			
		if player_id == 0 or can_start:
			return
			
		if event.is_action_pressed("select"):
			if chosen_button:
				chosen_button.unchoose()

			chosen_button = buttons[current_index]
			chosen_button.choose()
			update_confirm_state()
				
		if event.is_action_pressed("ui_right"):
			current_index = clamp(current_index + 1, 0, buttons.size() - 1)
			update_outlines()

		if event.is_action_pressed("ui_left"):
			current_index = clamp(current_index - 1, 0, buttons.size() - 1)
			update_outlines()
			
func _handle_analog(delta: float):
	var device = player_devices.get(player_number)
	if device == null or can_start:
		return

	var value = Input.get_joy_axis(device, JOY_AXIS_LEFT_X)

	var dir := 0
	if value > analog_deadzone:
		dir = 1
	elif value < -analog_deadzone:
		dir = -1

	# Neutral stick
	if dir == 0:
		hold_timer = 0
		axis_direction = 0
		return

	# First tilt
	if dir != axis_direction:
		_move_player(dir)
		hold_timer = 0
		axis_direction = dir
		return

	# Holding
	hold_timer += delta

	if hold_timer > hold_delay:
		if int((hold_timer - hold_delay) / repeat_rate) > int((hold_timer - hold_delay - delta) / repeat_rate):
			_move_player(dir)
		
func _move_player(dir: int):
	current_index = clamp(current_index + dir, 0, buttons.size() - 1)
	update_outlines()
	
func update_confirm_state():
	if chosen_button != null:
		confirm_button.grab_focus()
		can_start = true
	else:
		confirm_button.release_focus()
		can_start = false
		
func _process(delta):
	if Input.joy_connection_changed:
		assign_devices()

	_handle_analog(delta)

func update_outlines():
	if buttons.is_empty():
		return
	outline.global_position = buttons[current_index].global_position + Vector2(16, 16)

func collect_buttons(node: Variant):
	for button in node.get_children():
		if button is UpgradeButton:
			buttons.append(button)
		collect_buttons(button)
	
func _on_confirm_button_pressed() -> void:
	if not chosen_button:
		return
	
	Global.upgrade_chosen(player_number, chosen_button.upgrade_data)
