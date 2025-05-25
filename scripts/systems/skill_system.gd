extends Node

class_name SkillSystem

# Skill properties
var current_level: int = 1
var current_xp: float = 0.0

# Constants for XP curve scaling
const XP_BASE := 10.0
const XP_SCALING_LEVELS := [
    {"max_level": 10, "rate": 0.35},
    {"max_level": 20, "rate": 0.30},
    {"max_level": 30, "rate": 0.25},
    {"max_level": 40, "rate": 0.20},
    {"max_level": 50, "rate": 0.15},
    {"max_level": 1000, "rate": 0.10}  # cap for infinite levels
]

# Skill gain per proc
const BASE_SKILL_GAIN := 0.1

# Proc chances
const BASE_PROC_CHANCE := 7.5
const ELITE_PROC_BONUS := 2.5
const BOSS_PROC_BONUS := 5.0

func _init():
    current_level = 1
    current_xp = 0.0

func xp_required(level: int) -> float:
    # Calculates XP required to next level based on scaling tiers
    var xp_needed = XP_BASE
    var last_max = 0
    for tier in XP_SCALING_LEVELS:
        if level <= tier["max_level"]:
            var levels_in_tier = level - last_max
            # geometric progression formula: XP_BASE * (1 + rate)^(levels_in_tier - 1)
            xp_needed = XP_BASE * pow(1 + tier["rate"], levels_in_tier - 1)
            return ceil(xp_needed)
        last_max = tier["max_level"]
    # fallback for very high levels
    return XP_BASE * pow(1 + XP_SCALING_LEVELS[-1]["rate"], level - last_max)

func gain_xp(amount: float) -> bool:
    # Adds XP, returns true if leveled up
    current_xp += amount
    var leveled_up = false
    while current_xp >= xp_required(current_level):
        current_xp -= xp_required(current_level)
        current_level += 1
        leveled_up = true
    return leveled_up

func calculate_proc_chance(mob_type: String) -> float:
    var proc_chance = BASE_PROC_CHANCE
    if mob_type == "elite":
        proc_chance += ELITE_PROC_BONUS
    elif mob_type == "boss":
        proc_chance += BOSS_PROC_BONUS
    return proc_chance

func skill_gain_on_proc() -> float:
    return BASE_SKILL_GAIN
