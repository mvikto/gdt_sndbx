extends RayCast3D

@onready var grab_text : Label3D = $"GrabText"

var grab_target : RigidBody3D = null

var collided_body : RigidBody3D = null

func _ready() -> void:
	collide_with_areas = false
	collide_with_bodies = true
	grab_text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	grab_text.visible = false
	grab_text.text = "Press E to Grab"

func _physics_process(delta: float) -> void:
	var c := get_collider()
	if c is RigidBody3D:
		collided_body = c
	elif c == null:
		collided_body = null

func _process(_delta: float) -> void:
	if is_instance_valid(grab_target):
		grab_target.global_position = to_global(target_position)
		grab_target.move_and_collide(Vector3.ZERO)
	else:
		draw_grab_prompt()

func draw_grab_prompt() -> void:
	if not collided_body:
		grab_text.visible = false
		return
	grab_text.global_position = collided_body.global_position
	grab_text.visible = true

func _unhandled_input(event: InputEvent) -> void:
	var use_pressed := event.is_action_pressed("use")
	if use_pressed and is_instance_valid(grab_target):
		grab_target.freeze = false
		grab_target = null
		get_viewport().set_input_as_handled()
	elif use_pressed and is_instance_valid(collided_body):
		grab_target = collided_body
		grab_text.visible = false
		grab_target.freeze = true
		get_viewport().set_input_as_handled()
