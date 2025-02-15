class_name LevelEditorEntityWave
extends Node2D

# 	[[pos: Vector2, scene_path: String, neon_sprite: NeonSprite]]
var wave_contents: Array = []
var wave_index: int
var is_wave_selected: bool
var selected_entities: Array[NeonSprite] = []
var screen_space: LevelEditorScreenSpace

func _ready() -> void:
	screen_space = Utils.find_first_parent_of_type(self, LevelEditorScreenSpace)

	SignalBus.level_editor_select_wave.connect(func(wave: int) -> void:
		var neon_sprite_alpha_value: float = 1.0

		if wave == wave_index:
			is_wave_selected = true
		else:
			is_wave_selected = false
			neon_sprite_alpha_value = 0.02
			
			for neon_sprite: NeonSprite in get_children():
				deselect_entity(neon_sprite)

		for neon_sprite: NeonSprite in (get_children() as Array[NeonSprite]):
			neon_sprite.final_alpha = neon_sprite_alpha_value
	)

func _input(event: InputEvent) -> void:
	if not is_wave_selected:
		return

	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		if not screen_space.is_selection_rect_active:
			deselect_all_entities()

		for neon_sprite: NeonSprite in (get_children() as Array[NeonSprite]):
			var sprite_rect: Rect2 = neon_sprite._base_sprite.get_rect()
			if sprite_rect.has_point(neon_sprite._base_sprite.to_local(get_global_mouse_position())):
				deselect_all_entities()
				select_entity(neon_sprite)

	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_DELETE:
		for i in range(selected_entities.size() - 1, -1, -1):
			var inst: NeonSprite = selected_entities[i]
			if is_instance_valid(inst):
				remove_entity(inst)

	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE:
		deselect_all_entities()

func add_entity(pos: Vector2, neon_sprite: NeonSprite, scene_path: String) -> void:
	wave_contents.append([pos, scene_path, neon_sprite])
	add_child(neon_sprite)

func remove_entity(neon_sprite: NeonSprite) -> void:
	for i in range(wave_contents.size() - 1, -1, -1):
		var entity_entry: Array = wave_contents[i]
		var entry_neon_sprite: NeonSprite = entity_entry[2]

		if entry_neon_sprite == neon_sprite:
			neon_sprite.queue_free()
			remove_child(neon_sprite)

			wave_contents.remove_at(i)
			selected_entities.erase(neon_sprite)
			break

func select_entity(neon_sprite: NeonSprite) -> void:
	neon_sprite.final_tint = Color(0.5, 0.9, 1.0)
	if neon_sprite not in selected_entities:
		selected_entities.append(neon_sprite)

func deselect_entity(neon_sprite: NeonSprite) -> void:
	neon_sprite.final_tint = Color.WHITE
	selected_entities.erase(neon_sprite)

func deselect_all_entities() -> void:
	for i in range(selected_entities.size() - 1, -1, -1):
		var inst: NeonSprite = selected_entities[i]
		deselect_entity(inst)

func get_selected_entities() -> Array[NeonSprite]:
	return selected_entities
