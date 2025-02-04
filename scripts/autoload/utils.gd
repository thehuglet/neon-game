@tool
extends Node

func get_scene_tree() -> SceneTree:
	return get_tree()

func get_direction_to_target(origin: Vector2, target: Vector2) -> Vector2:
	return (target - origin).normalized()

func interpolate_fixed_step(current: Vector2, target: Vector2, step_size: float) -> Vector2:
	var angle_diff: float = target.angle_to(current)
	var clamped_rotation: float = clamp(angle_diff, -step_size, step_size)
	return current.rotated(-clamped_rotation).normalized()

func find_first_parent_of_type(node: Node, parent_type: Variant, _recursion_attempt: int = 0) -> Node:
	var max_recursion_attempts := 8
	var parent := node.get_parent()

	if is_instance_of(parent, parent_type):
		return parent

	if _recursion_attempt >= max_recursion_attempts:
		return null

	return find_first_parent_of_type(parent, parent_type, _recursion_attempt+1)
