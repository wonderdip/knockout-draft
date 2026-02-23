extends Node
class_name ComboBuffer

var buffer: Array = []
var buffer_window: float = 0.5

# { "sequence": Array[String], "state_name": String }
var registered_combos: Array = []

func register(state_name: String, sequence: Array[String]) -> void:
	if sequence.is_empty():
		return
	registered_combos.append({ "state_name": state_name, "sequence": sequence })

func add_input(action: String) -> void:
	buffer.append({ "action": action, "time": Time.get_ticks_msec() / 1000.0 })
	print(buffer)
	
func _process(_delta: float) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	buffer = buffer.filter(func(e): return now - e.time < buffer_window)

## Returns the state name of the first matching combo, or empty string
func check_all() -> String:
	var actions = buffer.map(func(e): return e.action)
	for combo in registered_combos:
		var seq_idx = 0
		for action in actions:
			if action == combo.sequence[seq_idx]:
				seq_idx += 1
			if seq_idx == combo.sequence.size():
				clear()
				print(combo.state_name)
				return combo.state_name
	return ""

func clear() -> void:
	buffer.clear()
