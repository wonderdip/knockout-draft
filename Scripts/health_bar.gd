extends TextureProgressBar
class_name GradientHealthBar

## Gradient health bar that connects to player automatically
## Supports smooth transitions and color updates

@export var smooth_transition: bool = true
@export var transition_speed: float = 10.0
@export var update_gradient_color: bool = false  # Update gradient based on health

var target_value: float = 100.0
var player: Player = null

func _ready() -> void:
	# Wait for scene to load
	await get_tree().process_frame
	
	# Find and connect to player
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
		if player.has_signal("health_changed"):
			player.health_changed.connect(_on_health_changed)
			# Initialize with current health
			max_value = player.max_health
			value = player.current_health
			target_value = player.current_health

func _process(delta: float) -> void:
	if smooth_transition and value != target_value:
		value = lerp(value, target_value, transition_speed * delta)
		
		# Optional: Update gradient color dynamically
		if update_gradient_color:
			update_gradient_colors(value / max_value)

func _on_health_changed(current: float, maximum: float) -> void:
	max_value = maximum
	
	if smooth_transition:
		target_value = current
	else:
		value = current
	
	# Update gradient if enabled
	if update_gradient_color:
		update_gradient_colors(current / maximum)

## Updates gradient colors based on health percentage
func update_gradient_colors(percent: float) -> void:
	# Check if we have a GradientTexture2D
	if not texture_progress is GradientTexture2D:
		return
	
	var grad_texture = texture_progress as GradientTexture2D
	if not grad_texture.gradient:
		return
	
	var gradient = grad_texture.gradient
	
	# Modify gradient colors based on health
	# This creates a color shift effect
	if percent > 0.6:
		# Healthy - more green
		gradient.set_color(0, Color.LIME_GREEN)
		gradient.set_color(1, Color.GREEN)
	elif percent > 0.3:
		# Damaged - yellow to orange
		gradient.set_color(0, Color.YELLOW)
		gradient.set_color(1, Color.ORANGE)
	else:
		# Critical - red
		gradient.set_color(0, Color.ORANGE_RED)
		gradient.set_color(1, Color.RED)
