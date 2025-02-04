@tool
class_name LevelEditorEntityListSlot
extends AspectRatioContainer

@onready var neon_sprite: NeonSprite = %NeonSprite
@onready var panel: Panel = %Panel
@onready var _draggable_preview_scene: PackedScene = preload('res://scenes/level_editor/ui/entity_list/slot/draggable_preview.tscn')

var _entity_scene_path: String

func _ready() -> void:
	resized.connect(_on_resize)

func _on_resize() -> void:
	# Ensures the container is a square
	# for the grid container
	custom_minimum_size.y = size.x

func _get_drag_data(at_position: Vector2) -> String:
	var preview: LevelEditorDraggablePreview = _draggable_preview_scene.instantiate()
	preview.neon_sprite.base_texture = neon_sprite.base_texture
	preview.neon_sprite.glow_texture = neon_sprite.glow_texture
	preview.neon_sprite.color = neon_sprite.color
	set_drag_preview(preview)

	return _entity_scene_path

# func _get_drag_data(at_position: Vector2) -> Variant:
# 	var inst = neon_sprite.duplicate()
# 	add_child(inst)
# 	print(inst)
# 	return inst

	# func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# 	return data is NeonSprite

# func _drop_data(at_position: Vector2, data: Variant) -> void:
# 	neon_sprite = data
