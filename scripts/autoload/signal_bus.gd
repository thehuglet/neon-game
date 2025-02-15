@tool
extends Node

signal level_editor_add_entity(position: Vector2, neon_sprite: NeonSprite, entity_scene_path: String)
signal level_editor_select_wave(wave: int)
signal level_editor_field_item_dragged
signal level_editor_field_item_dropped
