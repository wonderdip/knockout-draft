extends TextureButton
class_name CharacterSelectorbutton

signal character_chosen(player_id: int, fighter: Fighter)

@export var character: PackedScene

func choose(player_id: int):
	if character:
		var fighter = character.instantiate() as Fighter
		character_chosen.emit(player_id, fighter)
		modulate = Color(0.5, 0.5, 0.5)
		print(player_id, fighter, self)
		
func unchoose():
	modulate = Color.WHITE
