extends Node
class_name InteractionSystem

@export var interact_cooldown := 2.0        # Base cooldown in seconds
@export var max_spam_threshold := 20        # Max allowed uses per minute before penalty
@export var spam_cooldown := 30.0           # Cooldown if player is spamming
@export var ray_length := 3.0               # Max distance to interact

var _last_interact_time := 0.0
var _interact_history: Array[float] = []

var player_node: Node = null
var raycast: RayCast3D = null

func _ready():
	if not is_inside_tree(): return
	set_process(true)

func initialize(p_player_node: Node, p_raycast: RayCast3D) -> void:
	player_node = p_player_node
	raycast = p_raycast

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_try_interact()

func _try_interact() -> void:
	var current_time := Time.get_ticks_msec() / 1000.0
	_cleanup_history(current_time)

	var cooldown := interact_cooldown
	if _interact_history.size() >= max_spam_threshold:
		cooldown = spam_cooldown
		_show_message("Interaction spam detected. Cooldown increased.")

	if current_time - _last_interact_time < cooldown:
		var remaining := cooldown - (current_time - _last_interact_time)
		_show_message("Interact cooldown: %.1f seconds" % remaining)
		return

	_last_interact_time = current_time
	_interact_history.append(current_time)

	if raycast and raycast.is_colliding():
		var target := raycast.get_collider()
		if target and target.has_method("interact"):
			target.interact(player_node)
			_show_message("Interacted with %s." % target.name)
		else:
			_show_message("Nothing to interact with.")
	else:
		_show_message("No target in range.")

func _cleanup_history(current_time: float) -> void:
	# Remove entries older than 60 seconds
	while _interact_history.size() > 0 and current_time - _interact_history[0] > 60.0:
		_interact_history.remove_at(0)

func _show_message(message: String) -> void:
	if player_node and player_node.has_method("show_local_message"):
		player_node.show_local_message(message)
	else:
		print("[Interaction]:", message)
