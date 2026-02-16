extends Node2D
class_name PunchingBag

func _on_area_2d_area_entered(area: Area2D) -> void:
	var player = area.get_parent() as Player
	if player:
		player.framefreeze(0.4, 0)
		print("hit")


func _on_area_2d_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
