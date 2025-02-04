class_name ChaseTargetEntityMovementStrategy
extends EntityMovementStrategy

# TODO: maybe add target selector options
# like 'nearest', 'furthest', etc.
@export var target_group: String
@export var turn_rate: float = 0.0      ## Set to [code]0[/code] for instant turning

var _current_direction: Vector2

func calculate_position_offset(delta: float, current_position: Vector2) -> Vector2:
	var target: Node2D = Utils.get_scene_tree().get_nodes_in_group(target_group).pop_front()
	if not target:
		return Vector2.ZERO
	
	var direction_to_target: Vector2 = Utils.get_direction_to_target(current_position, target.position)

	if turn_rate == 0.0:
		return direction_to_target

	if not _current_direction:
		_current_direction = direction_to_target

	_current_direction = Utils.interpolate_fixed_step(_current_direction, direction_to_target, turn_rate * delta)
	return _current_direction
