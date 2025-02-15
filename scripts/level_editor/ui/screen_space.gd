class_name LevelEditorScreenSpace
extends Control

var is_item_being_dragged: bool = false
# @onready var wave_container: Node2D = %EntityWaveContainer
@onready var _selection_rect: ColorRect = %SelectionRect
var is_selection_rect_active: bool = false
var selection_rect_start_pos: Vector2
var selection_rect_area := Rect2()
var level_editor: LevelEditor
var moved_wave_entities: Array[NeonSprite]
var is_wave_entity_being_moved: bool = false
var wave_entities_cursor_offsets: Dictionary = {}

func _ready() -> void:
	level_editor = Utils.find_first_parent_of_type(self, LevelEditor)

	SignalBus.level_editor_field_item_dragged.connect(func() -> void: is_item_being_dragged = true)
	SignalBus.level_editor_field_item_dropped.connect(func() -> void: is_item_being_dragged = false)

func _physics_process(delta: float) -> void:
	var draggable_preview_children: Array = get_children() \
		.filter(
			func(node: Node) -> bool: return node is LevelEditorDraggablePreview
		)

	if not (draggable_preview_children and is_item_being_dragged):
		if not is_wave_entity_being_moved:
			# this runs when the item has been dropped,
			# but the dropped signal has not fired yet
			SignalBus.level_editor_field_item_dropped.emit()
		

func _process(delta: float) -> void:
	if is_wave_entity_being_moved:
		for entity in moved_wave_entities:
			entity.position = get_global_mouse_position() + wave_entities_cursor_offsets[entity]
			for entry: Array in level_editor.waves[level_editor.selected_wave_index].wave_contents:
				if entry[2] == entity:
					entry[0] = entity.position

	elif is_selection_rect_active:
		if get_global_mouse_position().x < selection_rect_start_pos.x:
			_selection_rect.scale.x = -1
		elif get_global_mouse_position().x > selection_rect_start_pos.x:
			_selection_rect.scale.x = 1
		if get_global_mouse_position().y < selection_rect_start_pos.y:
			_selection_rect.scale.y = -1
		elif get_global_mouse_position().y > selection_rect_start_pos.y:
			_selection_rect.scale.y = 1

		var new_size: Vector2 = abs(get_global_mouse_position() - selection_rect_start_pos)
		selection_rect_area.size = new_size
		_selection_rect.size = new_size

		var neg_adj_rect_start_pos: Vector2 = selection_rect_start_pos
		var neg_adj_rect_end_pos: Vector2 = get_global_mouse_position()

		if neg_adj_rect_end_pos[0] < neg_adj_rect_start_pos[0]:
			selection_rect_area.position[0] = neg_adj_rect_end_pos[0]
			selection_rect_area.end[0] = neg_adj_rect_start_pos[0]
		if neg_adj_rect_end_pos[1] < neg_adj_rect_start_pos[1]:
			selection_rect_area.position[1] = neg_adj_rect_end_pos[1]
			selection_rect_area.end[1] = neg_adj_rect_start_pos[1]
			
		_tint_selected_entities()

func _get_drag_data(at_position: Vector2) -> Variant:
	var is_trying_to_move_entity: bool = false
	var selected_wave: LevelEditorEntityWave = level_editor.waves[level_editor.selected_wave_index]

	for neon_sprite: NeonSprite in (selected_wave.get_children() as Array[NeonSprite]):
		var sprite_rect: Rect2 = neon_sprite._base_sprite.get_rect()
		if sprite_rect.has_point(neon_sprite._base_sprite.to_local(get_global_mouse_position())):
			if level_editor.waves[level_editor.selected_wave_index].selected_entities.size() == 1:
				level_editor.waves[level_editor.selected_wave_index].deselect_all_entities()

			is_trying_to_move_entity = true
			level_editor.waves[level_editor.selected_wave_index].select_entity(neon_sprite)
			break

	if is_trying_to_move_entity:
		for neon_sprite: NeonSprite in (selected_wave.get_children() as Array[NeonSprite]):
			# var sprite_rect: Rect2 = neon_sprite._base_sprite.get_rect()
			# if sprite_rect.has_point(neon_sprite._base_sprite.to_local(get_global_mouse_position())):
			if neon_sprite in level_editor.waves[level_editor.selected_wave_index].selected_entities:
				# selected_wave.deselect_all_entities()
				moved_wave_entities.append(neon_sprite)
				is_wave_entity_being_moved = true
				wave_entities_cursor_offsets[neon_sprite] = neon_sprite.position - get_global_mouse_position()
		SignalBus.level_editor_field_item_dragged.emit()
		return EntityMove.new()

	else:
		is_selection_rect_active = true
		_selection_rect.visible = true
		selection_rect_start_pos = get_global_mouse_position()
		_selection_rect.position = selection_rect_start_pos
		selection_rect_area.position = selection_rect_start_pos
		return SelectionRect.new()

func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and (event as InputEventMouseButton).button_index == 1
		and event.is_released()
	):
		if is_selection_rect_active:
			is_selection_rect_active = false
			_selection_rect.visible = false
		elif is_wave_entity_being_moved:
			is_wave_entity_being_moved = false
			moved_wave_entities.clear()
			wave_entities_cursor_offsets.clear()
			SignalBus.level_editor_field_item_dropped.emit()

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is SelectionRect:
		# this is here to prevent selection behavior
		# from interacting with drag-drop behavior
		return
	if data is EntityMove:
		return

	SignalBus.level_editor_field_item_dropped.emit()

	if Input.is_key_pressed(KEY_SHIFT):
		var snap_step := get_viewport().get_visible_rect().size[1] / 45
		at_position = at_position.snappedf(snap_step)

	var entity_scene_path: String = data[0]
	var entity_neon_sprite: NeonSprite = data[1]

	SignalBus.level_editor_add_entity.emit(at_position, entity_neon_sprite, entity_scene_path)

func _tint_selected_entities() -> void:
	var selected_wave: LevelEditorEntityWave = level_editor.waves[level_editor.selected_wave_index]
	var wave_contents: Array = selected_wave.wave_contents

	for entity_entry: Array in wave_contents:
		var pos: Vector2 = entity_entry[0]
		var neon_sprite: NeonSprite = entity_entry[2]

		if selection_rect_area.has_point(pos):
			selected_wave.select_entity(neon_sprite)
		else:
			selected_wave.deselect_entity(neon_sprite)

class SelectionRect:
	# dummy class only used to differentiate
	# between drag-drop and selection rects
	# in _drop_data
	pass

class EntityMove:
	pass
