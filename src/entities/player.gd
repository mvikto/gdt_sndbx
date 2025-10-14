extends CharacterBody3D

@export var camera: Camera3D

@export var walking_speed := 7.0
@export var running_speed := 10.0
@export var mouse_sensitivity := 0.1
@export_range(0.0, 1.0) var movement_transition_speed := 0.05
@export var jump_velocity := 5.0

var running := false

func is_mouse_captured():
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

func _input(event):
	if not is_mouse_captured():
		return
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))

		var x_rot := deg_to_rad(-event.relative.y * mouse_sensitivity)
		var new_rot := camera.rotation_degrees.x + rad_to_deg(x_rot)
		camera.rotation_degrees.x = clamp(new_rot, -89, 89)

	running = Input.is_action_pressed("sprint")

	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = jump_velocity

func _process(_delta):
	if not is_mouse_captured():
		return

	# wasd
	if is_on_floor():
		var horizontal := Input.get_axis("move_left", "move_right")
		var move_forward := Input.get_axis("move_forward", "move_backward")

		var direction := Vector3(horizontal, 0, move_forward).normalized()
		direction = global_transform.basis * direction
		var speed := running_speed if running else walking_speed

		var old_y := velocity.y
		var new_velocity := velocity.lerp(direction * speed, _delta * (1/movement_transition_speed))
		new_velocity.y = old_y
		velocity = new_velocity

func _physics_process(delta: float) -> void:
	move_and_slide()
	velocity += get_gravity() * delta
