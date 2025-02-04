class_name Player
extends Entity

@export var _neon_sprite: NeonSprite

func _process(delta: float) -> void:
	var angle_to_cursor: float = (get_global_mouse_position() - position).angle()
	var new_rotation: float = lerp_angle(_neon_sprite.rotation, angle_to_cursor, 15.0 * delta)
	_neon_sprite.rotation = new_rotation
	# _neon_trail.update_rotation(new_rotation)
