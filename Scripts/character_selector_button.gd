extends TextureButton
class_name CharacterSelectorbutton

@export var character: PackedScene

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	if character:
		var player = character.instantiate() as Player
		add_child(player)
		player.name = player.fighter_name
		print(player.fighter_name)
