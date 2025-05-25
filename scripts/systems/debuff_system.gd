extends Node

# DebuffSystem.gd
# Manages debuffs on an entity: applying, updating, and removing debuffs

class_name DebuffSystem

# A debuff structure to hold debuff data
class Debuff:
	var name: String
	var duration: float
	var time_left: float
	var stacks: int
	var effect_strength: float
	var on_apply: Callable = null
	var on_remove: Callable = null
	var on_tick: Callable = null
	var tick_interval: float = 1.0
	var tick_timer: float = 0.0

	func _init(_name: String, _duration: float, _effect_strength: float = 0.0, _stacks: int = 1,
			_on_apply: Callable = null, _on_remove: Callable = null, _on_tick: Callable = null,
			_tick_interval: float = 1.0):
		name = _name
		duration = _duration
		time_left = _duration
		effect_strength = _effect_strength
		stacks = _stacks
		on_apply = _on_apply
		on_remove = _on_remove
		on_tick = _on_tick
		tick_interval = _tick_interval
		tick_timer = 0.0

var active_debuffs := {}

func _process(delta: float) -> void:
	# Update all active debuffs timers and apply tick effects
	var to_remove := []
	for debuff_name in active_debuffs.keys():
		var debuff = active_debuffs[debuff_name]
		debuff.time_left -= delta
		if debuff.on_tick != null:
			debuff.tick_timer += delta
			if debuff.tick_timer >= debuff.tick_interval:
				debuff.tick_timer = 0.0
				debuff.on_tick.call(debuff)
		if debuff.time_left <= 0:
			to_remove.append(debuff_name)
	for name in to_remove:
		_remove_debuff(name)

func add_debuff(name: String, duration: float, effect_strength: float = 0.0, stacks: int = 1,
		on_apply: Callable = null, on_remove: Callable = null, on_tick: Callable = null, tick_interval: float = 1.0) -> void:
	
	if active_debuffs.has(name):
		# Refresh duration and increase stacks if applicable
		var debuff = active_debuffs[name]
		debuff.time_left = max(debuff.time_left, duration)
		debuff.duration = max(debuff.duration, duration)
		debuff.stacks += stacks
		debuff.effect_strength = effect_strength # You may decide how to handle stacking effects
	else:
		var debuff = Debuff.new(name, duration, effect_strength, stacks, on_apply, on_remove, on_tick, tick_interval)
		active_debuffs[name] = debuff
		if on_apply != null:
			on_apply.call(debuff)

func _remove_debuff(name: String) -> void:
	if active_debuffs.has(name):
		var debuff = active_debuffs[name]
		if debuff.on_remove != null:
			debuff.on_remove.call(debuff)
		active_debuffs.erase(name)

func has_debuff(name: String) -> bool:
	return active_debuffs.has(name)

func get_debuff(name: String) -> Debuff:
	return active_debuffs.get(name, null)

func clear_all_debuffs() -> void:
	for name in active_debuffs.keys():
		_remove_debuff(name)
