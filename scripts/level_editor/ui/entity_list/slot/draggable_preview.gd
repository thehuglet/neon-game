class_name LevelEditorDraggablePreview
extends Container

@export var neon_sprite: NeonSprite

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		var snap_step := get_viewport().get_visible_rect().size[1] / 45
		position = position.snappedf(snap_step)
