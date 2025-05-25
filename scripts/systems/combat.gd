extends Node

signal skill_gained(skill_name: String, amount: int)
signal damage_dealt(target, amount: float)
signal target_killed(target)

@export var base_damage: float = 10.0
@export var damage_variance: float = 0.15  # ±15%
@export var skill_name: String = "Combat"
@export var skill_gain_amount: int = 1
@export var skill_proc_base: float = 0.125  # 12.5%

var owner_level := 1  # Set this from your player or enemy data
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func perform_attack(target: Node, owner_level: int, target_level: int):
	if not target.has_method("apply_damage"):
		return

	# Random damage variance
	var variance := 1.0 + rng.randf_range(-damage_variance, damage_variance)
	var final_damage := base_damage * variance
	final_damage = round(final_damage)

	# Apply damage
	var target_alive = target.apply_damage(final_damage)
	emit_signal("damage_dealt", target, final_damage)

	# Emit kill signal if dead
	if not target_alive:
		emit_signal("target_killed", target)

	# Try skill gain
	var chance = calculate_skill_gain_chance(owner_level, target_level)
	if rng.randf() < chance:
		emit_signal("skill_gained", skill_name, skill_gain_amount)

func calculate_skill_gain_chance(player_lvl: int, enemy_lvl: int) -> float:
	var diff = enemy_lvl - player_lvl
	var adjusted_chance = skill_proc_base + (diff * 0.0075)
	return clamp(adjusted_chance, 0.05, 0.20)  # Never lower than 5%, max 20%
