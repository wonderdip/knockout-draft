extends Node2D
class_name PunchingBag


@onready var pivot: Marker2D = $Pivot

func _on_area_2d_area_entered(area: Area2D) -> void:
	# add additional feedback here like:
	# - Spawn hit particles
	# - Play hit sound
	# - Show damage numbers
	# - Apply knockback to bag
	
	print("Bag hit!")
	
	# Optional: Make the bag swing or react visually
	var tween = create_tween()
	tween.tween_property(pivot, "rotation", -0.1, 0.1)
	tween.tween_property(pivot, "rotation", 0.1, 0.1)
	tween.tween_property(pivot, "rotation", 0.0, 0.1)

func _on_area_2d_area_exited(area: Area2D) -> void:
	pass
