class_name PlayerMovementEntityMovementStrategy
extends EntityMovementStrategy

func calculate_position_offset(delta: float, current_position: Vector2) -> Vector2:
	return Input.get_vector('left', 'right', 'up', 'down')
