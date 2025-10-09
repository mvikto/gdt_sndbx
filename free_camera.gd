extends Camera3D

var speed := 10.0
var mouse_sensitivity := 0.1
var velocity := Vector3.ZERO


func is_mouse_captured():
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if not is_mouse_captured():
		return
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		var x_rot = deg_to_rad(-event.relative.y * mouse_sensitivity)
		var new_rot = rotation_degrees.x + rad_to_deg(x_rot)
		rotation_degrees.x = clamp(new_rot, -89, 89)
		
func _process(delta):
	if not is_mouse_captured():
		return
	var vertical = - Input.get_axis("move_up", "move_down")
	
	var input_dir = Vector3(
		Input.get_axis("move_left", "move_right"),
		0,
		Input.get_axis("move_forward", "move_backward"),
	)

	var local_up = basis.inverse() * (Vector3.UP * vertical)
	input_dir += local_up

	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		velocity = input_dir * speed
	else:
		velocity = Vector3.ZERO

	translate_object_local(velocity * delta)
