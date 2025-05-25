extends Node

# Signals for global events
signal player_died
signal level_up(new_level)
signal game_saved
signal game_loaded

@export var save_file_path := "user://savegame.json"

var player_data := {}
var is_game_over := false

func _ready():
    # Attempt to load save on start
    if FileAccess.file_exists(save_file_path):
        load_game()
    else:
        reset_game()

func reset_game():
    # Initialize a fresh game state
    player_data = {
        "level": 1,
        "experience": 0,
        "health": 100,
        "stats": {
            "strength": 1.0,
            "agility": 1.0,
            "intelligence": 1.0,
        },
        "skills": {
            "weapon_handling": 0.0,
            "coordination": 0.0,
            "aim": 0.0,
            "long_range": 0.0,
            "short_range": 0.0,
            "melee": 0.0
        },
        "gold": 0,
        "inventory": [],
        "position": Vector3.ZERO
    }
    is_game_over = false

func save_game():
    var file = FileAccess.open(save_file_path, FileAccess.WRITE)
    if file:
        var save_dict = {
            "player_data": player_data
        }
       var json = json.stringify(data)
        file.close()
        emit_signal("game_saved")
        print("Game saved successfully.")
    else:
        push_error("Failed to open save file for writing.")

func load_game():
    var file = FileAccess.open(save_file_path, FileAccess.READ)
    if file:
        var data = file.get_as_text()
        file.close()
		var result = JSON.parse(json_string)
		if result.error == OK:
			var parsed = result.result
        if typeof(save_dict) == TYPE_DICTIONARY and "player_data" in save_dict:
            player_data = save_dict["player_data"]
            emit_signal("game_loaded")
            print("Game loaded successfully.")
        else:
            push_error("Save data corrupt or invalid format.")
            reset_game()
    else:
        push_error("Save file not found.")
        reset_game()

func apply_experience(amount):
    if is_game_over:
        return
    player_data["experience"] += amount
    _check_level_up()

func _check_level_up():
    var current_level = player_data["level"]
    var required_exp = _exp_required_for_level(current_level + 1)
    if player_data["experience"] >= required_exp:
        player_data["level"] += 1
        emit_signal("level_up", player_data["level"])
        print("Leveled up to %d!" % player_data["level"])

func _exp_required_for_level(level):
    # Example exponential exp curve: 100 * 1.5^(level-1)
    return int(100 * pow(1.5, level - 1))

func apply_damage(amount):
    if is_game_over:
        return
    player_data["health"] = max(player_data["health"] - amount, 0)
    print("Player took %d damage, health now %d." % [amount, player_data["health"]])
    if player_data["health"] <= 0:
        _on_player_death()

func _on_player_death():
    is_game_over = true
    emit_signal("player_died")
    print("Player has died. Game over.")

func add_gold(amount):
    player_data["gold"] += amount
    print("Gold now: %d" % player_data["gold"])

func add_item_to_inventory(item):
    player_data["inventory"].append(item)
    print("Added item: %s" % str(item))

func set_player_position(pos: Vector3):
    player_data["position"] = pos

func get_player_position() -> Vector3:
    return player_data.get("position", Vector3.ZERO)

func is_game_over_func() -> bool:
    return is_game_over
