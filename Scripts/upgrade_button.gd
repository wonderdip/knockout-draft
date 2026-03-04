extends TextureButton
class_name UpgradeButton

@export var upgrade_data: UpgradeData

func choose():
	# purely visual
	scale = Vector2(1.1, 1.1)
	
func unchoose():
	modulate = Color.WHITE
	
