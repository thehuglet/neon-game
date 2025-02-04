class_name Roto
extends Entity

@export var _neon_sprite: NeonSprite

func _process(delta: float) -> void:
	_neon_sprite.rotation += 7.5 * delta
