extends Node
class_name DebuffSystem

# Structure of a debuff
class Debuff:
	var name: String
	var strength: float
	var duration: float
	var remaining: float

	func _init(name: String, strength: float, duration: float):
		self.name = name
		self.strength = strength
		self.duration = duration
		self.remaining = duration

var active_debuffs: Array[Debuff] = []

signal debuff_applied(debuff_name: String)
signal debuff_removed(debuff_name: String)

func _process(delta: float) -> void:
	for debuff in active_debuffs:
		debuff.remaining -= delta
		if debuff.remaining <= 0:
			remove_debuff(debuff.name)

# Apply or refresh a debuff
func apply_debuff(name: String, strength: float, duration: float) -> void:
	var existing = get_debuff(name)
	if existing:
		existing.strength = strength
		existing.duration = duration
		existing.remaining = duration
	else:
		var debuff = Debuff.new(name, strength, duration)
		active_debuffs.append(debuff)
		emit_signal("debuff_applied", name)

# Remove a debuff manually
func remove_debuff(name: String) -> void:
	for debuff in active_debuffs:
		if debuff.name == name:
			active_debuffs.erase(debuff)
			emit_signal("debuff_removed", name)
			break

# Check if a debuff is active
func has_debuff(name: String) -> bool:
	return get_debuff(name) != null

# Get strength of a specific debuff
func get_debuff_strength(name: String) -> float:
	var d = get_debuff(name)
	return d.strength if d else 0.0

# Internal helper
func get_debuff(name: String) -> Debuff:
	for debuff in active_debuffs:
		if debuff.name == name:
			return debuff
	return null

# Optional: clear all debuffs
func clear_all_debuffs() -> void:
	for debuff in active_debuffs.duplicate():
		remove_debuff(debuff.name)
