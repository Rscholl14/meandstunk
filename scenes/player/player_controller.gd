extends CharacterBody3D

@export var speed := 5.0
@export var mouse_sensitivity := 0.2
@export var jump_velocity := 4.5
@export var gravity := Vector3.DOWN * 9.8

var camera: Camera3D
var is_zooming := false

var skill_system: SkillSystem  # Use the global class name directly

func _ready():
	camera = $Camera3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_initialize_input_map()
	
	# Instantiate the global class directly
	skill_system = SkillSystem.new()

func _initialize_input_map():
	var bindings = {
		"move_forward": [KEY_W],
		"move_back": [KEY_S],
		"move_left": [KEY_A],
		"move_right": [KEY_D],
		"jump": [KEY_SPACE],
		"aim": [MOUSE_BUTTON_RIGHT],
		"ui_cancel": [KEY_ESCAPE]
	}

	for action in bindings.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			if not _has_key_in_action(action, key):
				var ev := InputEventKey.new()
				ev.physical_keycode = key
				InputMap.action_add_event(action, ev)

func _has_key_in_action(action: String, keycode: int) -> bool:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey and ev.physical_keycode == keycode:
			return true
	return false

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -75, 75)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	velocity.y += gravity.y * delta

	var input_dir := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	input_dir = input_dir.normalized()

	var direction = (transform.basis * input_dir).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	is_zooming = Input.is_action_pressed("aim")
	camera.fov = 40 if is_zooming else 70

	move_and_slide()

# Simulated skill gain method
func on_enemy_killed(mob_type: String = "normal"):
	var proc_chance = skill_system.calculate_proc_chance(mob_type)
	if randf() < proc_chance / 100.0:
		var skill_gain = skill_system.skill_gain_on_proc()
		var leveled_up = skill_system.gain_xp(skill_gain)
		if leveled_up:
			print("Skill leveled up! New level: %d" % skill_system.current_level)
