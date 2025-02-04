class_name EntityMovementStrategy
extends Resource

func _init() -> void:
	resource_local_to_scene = true

func calculate_position_offset(delta: float, current_position: Vector2) -> Vector2:
	push_error('Entity movement strategy "', resource_name, '" should implement the "calculate_position_offset() method"')
	return Vector2.ZERO
