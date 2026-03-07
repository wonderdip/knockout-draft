extends TextureButton
class_name UpgradeButton

@export var upgrade_data: UpgradeData

func choose():
	modulate = Color(0.5, 0.5, 0.5)
	
func unchoose():
	modulate = Color.WHITE
	
