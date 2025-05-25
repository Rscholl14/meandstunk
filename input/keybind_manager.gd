extends Node
class_name KeybindManager

# Optional: Save/load from a config file
const CONFIG_PATH := "user://keybinds.cfg"

# Define default bindings (extend as needed)
var default_bindings := {
	"move_forward": KEY_W,
	"move_back": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D,
	"jump": KEY_SPACE,
	"use_item": KEY_F,
	"aim": MOUSE_BUTTON_RIGHT,
	"ui_cancel": KEY_ESCAPE,
	"toggle_ui_lock": KEY_U
}

func _ready():
	load_or_initialize_bindings()

func load_or_initialize_bindings():
	for action in default_bindings.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)

		# Only apply defaults if no bindings present
		if InputMap.action_get_events(action).is_empty():
			var keycode := default_bindings[action]
			var event := create_input_event(keycode)
			InputMap.action_add_event(action, event)

	# Optional: load saved bindings
	if FileAccess.file_exists(CONFIG_PATH):
		_load_bindings_from_file(CONFIG_PATH)

func create_input_event(keycode: int) -> InputEvent:
	var ev: InputEvent
	if keycode >= KEY_SPACE:  # Keyboard
		ev = InputEventKey.new()
		ev.physical_keycode = keycode
	else:  # Mouse button
		ev = InputEventMouseButton.new()
		ev.button_index = keycode
	return ev

func rebind_action(action_name: String, new_keycode: int):
	# Remove current events
	InputMap.action_erase_events(action_name)

	# Add new one
	var ev = create_input_event(new_keycode)
	InputMap.action_add_event(action_name, ev)

	# Save to config
	_save_bindings_to_file(CONFIG_PATH)

func get_binding_for_action(action_name: String) -> InputEvent:
	var events = InputMap.action_get_events(action_name)
	return events[0] if events.size() > 0 else null

func reset_bindings_to_default():
	for action in default_bindings.keys():
		InputMap.action_erase_events(action)
		var ev = create_input_event(default_bindings[action])
		InputMap.action_add_event(action, ev)

	_save_bindings_to_file(CONFIG_PATH)

func _save_bindings_to_file(path: String):
	var config = ConfigFile.new()

	for action in default_bindings.keys():
		var event = get_binding_for_action(action)
		if event is InputEventKey:
			config.set_value("keybinds", action, event.physical_keycode)
		elif event is InputEventMouseButton:
			config.set_value("keybinds", action, event.button_index)

	config.save(path)

func _load_bindings_from_file(path: String):
	var config = ConfigFile.new()
	var err = config.load(path)
	if err != OK:
		push_error("Failed to load keybindings config")
		return

	for action in default_bindings.keys():
		if config.has_section_key("keybinds", action):
			var keycode = int(config.get_value("keybinds", action))
			rebind_action(action, keycode)
