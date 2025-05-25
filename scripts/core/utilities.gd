extends Node

class_name Utilities

static func roll_chance(percent: float) -> bool:
	# Rolls a chance (0.0 to 1.0). Accepts percent in 0–100.
	return randf() < clamp(percent / 100.0, 0.0, 1.0)

static func roll_range(min_value: float, max_value: float) -> float:
	# Returns a random float between min and max.
	return randf_range(min_value, max_value)

static func roll_range_int(min_value: int, max_value: int) -> int:
	# Returns a random int between min and max.
	return randi_range(min_value, max_value)

static func format_duration(seconds: int) -> String:
	# Converts seconds to mm:ss or hh:mm:ss
	var hrs = seconds / 3600
	var mins = (seconds % 3600) / 60
	var secs = seconds % 60

	if hrs > 0:
		return "%02d:%02d:%02d" % [hrs, mins, secs]
	else:
		return "%02d:%02d" % [mins, secs]

static func format_percent(value: float, decimals: int = 1) -> String:
	# Formats a float as a percent string with `decimals` digits.
	return "%.*f%%" % [decimals, value * 100]

static func calculate_skill_proc_chance(player_level: int, enemy_level: int) -> float:
	# Returns skill gain chance as a percent based on level difference.
	var base_chance := 12.5
	var diff := enemy_level - player_level
	var mod := clamp(diff * 0.75, -3.75, 3.75) # max ±5 levels
	return clamp(base_chance + mod, 5.0, 16.25)

static func safe_register_action(action_name: String, keys: Array[int]):
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for key in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = key
		InputMap.action_add_event(action_name, ev)
