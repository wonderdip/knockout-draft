extends Node

var camera: DynamicCamera

## Registers the camera for shake effects
func register_camera(cam: Camera2D) -> void:
	camera = cam

## Plays hit effects based on attack strength
func play_hit_effect(strength: HitStrength) -> void:
	match strength:
		HitStrength.LIGHT:
			play_light_hit()
		HitStrength.MEDIUM:
			play_medium_hit()
		HitStrength.HEAVY:
			play_heavy_hit()
		HitStrength.SUPER:
			play_super_hit()

## Light hit effect
func play_light_hit() -> void:
	frame_freeze(0.15, 0)
	if camera:
		camera.cam_shake(2, 0.5, 0.1)

## Medium hit effect
func play_medium_hit() -> void:
	frame_freeze(0.15, 0)
	if camera:
		camera.cam_shake(4, 1, 0.15)

## Heavy hit effect
func play_heavy_hit() -> void:
	frame_freeze(0.2, 0)
	
	if camera:
		camera.cam_shake(6, 1.5, 0.2)

## Super/critical hit effect
func play_super_hit() -> void:
	frame_freeze(0.25, 0)
	if camera:
		camera.cam_shake(8, 2, 0.3)

## Freezes the frame for a duration
func frame_freeze(duration: float, time_scale: float) -> void:
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

## Enum for hit strength levels
enum HitStrength {
	LIGHT,
	MEDIUM,
	HEAVY,
	SUPER
}
