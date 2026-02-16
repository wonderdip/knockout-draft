extends PlayerAttackState
class_name PlayerCrouchAttackState

func exit() -> void:
	print("uncrouching")
	player.hurtbox_collision_shape.position = Vector2(0, 0)
	player.hitbox.position = Vector2(0, 0)
	player.hitbox.shape.height = 74.0
