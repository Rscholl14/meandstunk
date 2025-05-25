extends Node

# CooldownManager.gd
# Manages multiple cooldowns by unique IDs (e.g., ability names)

class_name CooldownManager

# Dictionary storing cooldown data:
# key = cooldown ID (String), value = Dictionary {duration: float, time_left: float}
var cooldowns := {}

func _process(delta: float) -> void:
    var keys_to_remove := []
    for cd_id in cooldowns.keys():
        cooldowns[cd_id].time_left -= delta
        if cooldowns[cd_id].time_left <= 0:
            keys_to_remove.append(cd_id)
    for cd_id in keys_to_remove:
        cooldowns.erase(cd_id)

# Starts a cooldown for given ID and duration (in seconds).
# If cooldown already exists, it resets the time.
func start_cooldown(cd_id: String, duration: float) -> void:
    cooldowns[cd_id] = {
        "duration": duration,
        "time_left": duration
    }

# Returns true if the cooldown is currently active (not finished)
func is_on_cooldown(cd_id: String) -> bool:
    return cd_id in cooldowns and cooldowns[cd_id].time_left > 0

# Returns remaining time on cooldown, or 0 if not active
func get_cooldown_time_left(cd_id: String) -> float:
    if cd_id in cooldowns:
        return max(0.0, cooldowns[cd_id].time_left)
    return 0.0

# Resets/removes a cooldown immediately
func reset_cooldown(cd_id: String) -> void:
    cooldowns.erase(cd_id)

# Returns fraction (0.0 to 1.0) of cooldown progress: 1.0 means just started, 0 means finished
func get_cooldown_progress(cd_id: String) -> float:
    if cd_id in cooldowns:
        var cd = cooldowns[cd_id]
        return clamp(cd.time_left / cd.duration, 0.0, 1.0)
    return 0.0
