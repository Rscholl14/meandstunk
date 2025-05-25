extends Node

# InteractionSystem.gd
# Manages player interactions with objects in range

class_name InteractionSystem

@export var interaction_radius: float = 3.0
@export var interaction_key: String = "interact"  # Define in InputMap (e.g., E key)

# Reference to the player node to check position
var player: Node3D = null

# List of interactable objects currently in range
var interactables_in_range := []

func _ready():
    # Optionally get player reference if set as autoload or passed in
    if not player:
        player = get_parent().get_node_or_null("Player")
    # Connect input event if needed
    set_process(true)

func _process(delta: float) -> void:
    if not player:
        return

    # Update interactables in range every frame (can be optimized)
    _update_interactables_in_range()

    # Check for interaction input
    if Input.is_action_just_pressed(interaction_key):
        _try_interact()

func _update_interactables_in_range() -> void:
    interactables_in_range.clear()
    # Search for all interactables in the scene (could use groups)
    var interactables = get_tree().get_nodes_in_group("interactable")

    for interactable in interactables:
        if interactable is Node3D:
            var dist = player.global_transform.origin.distance_to(interactable.global_transform.origin)
            if dist <= interaction_radius:
                interactables_in_range.append(interactable)

func _try_interact() -> void:
    if interactables_in_range.empty():
        return

    # Find closest interactable
    var closest = null
    var closest_dist = interaction_radius + 1.0
    var player_pos = player.global_transform.origin

    for interactable in interactables_in_range:
        var dist = player_pos.distance_to(interactable.global_transform.origin)
        if dist < closest_dist:
            closest_dist = dist
            closest = interactable

    if closest and closest.has_method("interact"):
        closest.interact()
    else:
        # Optional: print("No interactable method found on object")
        pass
