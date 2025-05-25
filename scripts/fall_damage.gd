extends Node

class_name FallDamage

signal player_died
signal debuff_applied(percent: float, duration: float)

# Constants
const MIN_DAMAGE_HEIGHT := 5.0
const MAX_DAMAGE_HEIGHT := 30.0
const MAX_DAMAGE := 100
const DEBUFF_THRESHOLD := 49
const DEBUFF_MIN := 0.05
const DEBUFF_MAX := 0.25
const DURATION_MIN := 180  # seconds
const DURATION_MAX := 900  # seconds

var last_y: float = 0.0
var is_falling := false

func _physics_process(delta):
	if not get_parent().is_on_floor():
		if not is_falling:
			last_y = get_parent().global_position.y
			is_falling = true
	else:
		if is_falling:
			var current_y = get_parent().global_position.y
			var fall_distance = last_y - current_y
			is_falling = false
			_process_fall(fall_distance)

func _process_fall(distance: float):
	if distance < MIN_DAMAGE_HEIGHT:
		return  # too small to cause damage

	var player = get_parent()
	var damage = clamp((distance - MIN_DAMAGE_HEIGHT) / (MAX_DAMAGE_HEIGHT - MIN_DAMAGE_HEIGHT) * MAX_DAMAGE, 0, MAX_DAMAGE)
	damage = round(damage)

	# Apply damage
	player.health -= damage
	print("Fall Damage Taken: %s (Distance: %.2f meters)" % [damage, distance])

	if player.health <= 0:
		player.health = 0
		emit_signal("player_died")
		player.kill_player()
		print("Player died from falling.")
		return

	# Apply debuff if damage is high enough
	if damage > DEBUFF_THRESHOLD:
		var debuff_percent = randf_range(DEBUFF_MIN, DEBUFF_MAX)
		var duration = randi_range(DURATION_MIN, DURATION_MAX)
		player.apply_movement_debuff(debuff_percent, duration)
		emit_signal("debuff_applied", debuff_percent, duration)
		print("Movement debuff applied: %.2f%% for %s seconds" % [debuff_percent * 100, duration])
