class_name EntityMovement
extends Node

@export var strategy: EntityMovementStrategy

func _ready() -> void:
	strategy = strategy.duplicate()

func calculate_position_offset(delta: float, current_position: Vector2, movement_speed: int) -> Vector2:
	# TODO: implement push force uwu
	return (
		strategy.calculate_position_offset(delta, current_position)
		* movement_speed
		* delta
	)
