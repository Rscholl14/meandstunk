extends Node

# Signals
signal health_changed(current_health)
signal mana_changed(current_mana)
signal experience_changed(current_exp)
signal level_changed(new_level)
signal inventory_changed()
signal equipment_changed()
signal skills_changed()

# Player core stats
@export var max_health := 100
@export var max_mana := 50
@export var max_stamina := 100

var current_health := max_health
var current_mana := max_mana
var current_stamina := max_stamina

var level := 1
var experience := 0

# Stats dictionary for attributes like strength, agility, intelligence
var stats := {
    "strength": 10,
    "agility": 10,
    "intelligence": 10,
    "endurance": 10,
    "luck": 5
}

# Skills dictionary with skill name => skill level (float)
var skills := {
    "weapon_handling": 0.0,
    "coordination": 0.0,
    "aim": 0.0,
    "long_range": 0.0,
    "short_range": 0.0,
    "melee": 0.0
}

# Inventory: list of dictionaries/items (you can customize your item structure)
var inventory := []

# Equipment: dictionary slot_name => item
var equipment := {
    "head": null,
    "chest": null,
    "legs": null,
    "feet": null,
    "weapon": null,
    "shield": null
}

func _ready():
    # Initialize or load data here if needed
    pass

# --- Health/Mana/Stamina management ---

func apply_damage(amount: float) -> void:
    current_health = max(current_health - amount, 0)
    emit_signal("health_changed", current_health)
    if current_health == 0:
        _on_death()

func heal(amount: float) -> void:
    current_health = min(current_health + amount, max_health)
    emit_signal("health_changed", current_health)

func consume_mana(amount: float) -> bool:
    if current_mana >= amount:
        current_mana -= amount
        emit_signal("mana_changed", current_mana)
        return true
    return false

func restore_mana(amount: float) -> void:
    current_mana = min(current_mana + amount, max_mana)
    emit_signal("mana_changed", current_mana)

# --- Experience and Leveling ---

func add_experience(amount: int) -> void:
    experience += amount
    emit_signal("experience_changed", experience)
    _check_level_up()

func _check_level_up() -> void:
    var required_exp = _exp_required_for_level(level + 1)
    while experience >= required_exp:
        level += 1
        emit_signal("level_changed", level)
        experience -= required_exp
        required_exp = _exp_required_for_level(level + 1)
        print("Leveled up! New level: %d" % level)

func _exp_required_for_level(lvl: int) -> int:
    # Example exp curve: 100 * 1.5^(lvl-1)
    return int(100 * pow(1.5, lvl - 1))

# --- Inventory management ---

func add_item(item: Dictionary) -> void:
    inventory.append(item)
    emit_signal("inventory_changed")

func remove_item(item: Dictionary) -> bool:
    if item in inventory:
        inventory.erase(item)
        emit_signal("inventory_changed")
        return true
    return false

func has_item(item: Dictionary) -> bool:
    return item in inventory

# --- Equipment management ---

func equip_item(slot: String, item: Dictionary) -> void:
    equipment[slot] = item
    emit_signal("equipment_changed")

func unequip_item(slot: String) -> void:
    equipment[slot] = null
    emit_signal("equipment_changed")

func get_equipped_item(slot: String) -> Dictionary:
    return equipment.get(slot, null)

# --- Skills management ---

func increase_skill(skill_name: String, amount: float) -> void:
    if skill_name in skills:
        skills[skill_name] += amount
        emit_signal("skills_changed")

func get_skill_level(skill_name: String) -> float:
    return skills.get(skill_name, 0.0)

# --- Death handler ---

func _on_death() -> void:
    print("Player has died.")
    # You can emit a signal here or handle death logic

# --- Save and Load ---

func to_dict() -> Dictionary:
    return {
        "current_health": current_health,
        "current_mana": current_mana,
        "current_stamina": current_stamina,
        "level": level,
        "experience": experience,
        "stats": stats,
        "skills": skills,
        "inventory": inventory,
        "equipment": equipment
    }

func from_dict(data: Dictionary) -> void:
    current_health = data.get("current_health", max_health)
    current_mana = data.get("current_mana", max_mana)
    current_stamina = data.get("current_stamina", max_stamina)
    level = data.get("level", 1)
    experience = data.get("experience", 0)
    stats = data.get("stats", stats)
    skills = data.get("skills", skills)
    inventory = data.get("inventory", [])
    equipment = data.get("equipment", equipment)
    # Emit signals to update UI etc.
    emit_signal("health_changed", current_health)
    emit_signal("mana_changed", current_mana)
    emit_signal("experience_changed", experience)
    emit_signal("level_changed", level)
    emit_signal("inventory_changed")
    emit_signal("equipment_changed")
    emit_signal("skills_changed")
