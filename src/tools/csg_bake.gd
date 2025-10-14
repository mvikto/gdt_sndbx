@tool
extends Node3D

@export var texel_size : float = ProjectSettings.get("rendering/lightmapping/primitive_meshes/texel_size")
@export var create_missing_nodes := false
@export_tool_button("Bake", "Callable") var create_missing := do_create_missing_nodes

var csgs : Array[CSGShape3D] = []

func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	for child in get_children():
		if child is CSGShape3D:
			csgs.append(child)
	update_configuration_warnings()

func _on_child_entered_tree(child: Node) -> void:
	if child is CSGShape3D:
		csgs.append(child)
		update_configuration_warnings()

func _on_child_exiting_tree(child: Node) -> void:
	if child is CSGShape3D:
		csgs.erase(child)
		update_configuration_warnings()


func do_create_missing_nodes() -> void:
	for csg in csgs:
		var mesh_name := get_mesh_name(csg.name)
		var mesh_instance := try_get_mesh_instance(mesh_name)

		var collision_shape_name := get_collision_shape_name(csg.name)
		var collision_shape := try_get_collision_shape(collision_shape_name)

		if mesh_instance == null and create_missing_nodes:
			mesh_instance = MeshInstance3D.new()
			mesh_instance.name = mesh_name
			add_child(mesh_instance)
			mesh_instance.owner = get_tree().edited_scene_root
		if mesh_instance == null and not create_missing_nodes:
			push_error("No MeshInstance3D named {0} found.".format([mesh_name]))

		if collision_shape == null and create_missing_nodes:
			collision_shape = CollisionShape3D.new()
			collision_shape.name = collision_shape_name
			add_child(collision_shape)
			collision_shape.owner = get_tree().edited_scene_root
		if collision_shape == null and not create_missing_nodes:
			push_error("No CollisionShape3D named {0} found.".format([collision_shape_name]))

		if collision_shape != null:
			collision_shape.shape = csg.bake_collision_shape()

		if mesh_instance != null:
			var array_mesh := csg.bake_static_mesh()
			array_mesh.lightmap_unwrap(global_transform, texel_size)
			mesh_instance.mesh = array_mesh

	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	for csg in csgs:
		var mesh_name := get_mesh_name(csg.name)
		var mesh := try_get_mesh_instance(mesh_name)
		if mesh == null:
			warnings.append("No MeshInstance3D named {0} found.".format([mesh_name]))

		var collision_shape_name := get_collision_shape_name(csg.name)
		var collision_shape := try_get_collision_shape(collision_shape_name)
		if collision_shape == null:
			warnings.append("No CollisionShape3D named {0} found.".format([collision_shape_name]))

	return warnings


func get_mesh_name(csg_name : String) -> String:
	return csg_name + "Mesh"

func get_collision_shape_name(csg_name : String) -> String:
	return csg_name + "CollisionShape"

func try_get_mesh_instance(csg_name: String) -> MeshInstance3D:
	var node := get_node_or_null(csg_name)
	if node == null:
		return null

	if node is MeshInstance3D:
		return node
	return null

func try_get_collision_shape(csg_name: String) -> CollisionShape3D:
	var node := get_node_or_null(csg_name)
	if node == null:
		return null

	if node is CollisionShape3D:
		return node
	return null
