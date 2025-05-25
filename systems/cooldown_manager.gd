extends Node
class_name CooldownManager

# Stores cooldowns with their end times (in seconds)
var _cooldowns := {}

func _process(_delta: float) -> void:
	_cleanup_expired()

# Starts a cooldown for a named action
func start_cooldown(name: String, duration: float) -> void:
	var current_time := Time.get_ticks_msec() / 1000.0
	_cooldowns[name] = current_time + duration

# Returns true if the named cooldown is active
func is_on_cooldown(name: String) -> bool:
	var current_time := Time.get_ticks_msec() / 1000.0
	return _cooldowns.has(name) and _cooldowns[name] > current_time

# Returns the remaining time (in seconds) for a named cooldown
func get_remaining_cooldown(name: String) -> float:
	var current_time := Time.get_ticks_msec() / 1000.0
	if _cooldowns.has(name):
		return max(_cooldowns[name] - current_time, 0)
	return 0.0

# Removes a cooldown manually (optional)
func clear_cooldown(name: String) -> void:
	_cooldowns.erase(name)

# Removes expired cooldowns from the dictionary
func _cleanup_expired() -> void:
	var current_time := Time.get_ticks_msec() / 1000.0
	for key in _cooldowns.keys():
		if _cooldowns[key] <= current_time:
			_cooldowns.erase(key)
