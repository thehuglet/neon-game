@tool
class_name LevelEditor
extends Node2D

@export var level_name: String = 'My Level'
@export_range(0.0, 60.0, 0.5) var wave_spawn_delay_sec: float
@export var btn_multiple_0: Array:
	get: return [
		{
			'text': 'Add Wave',
			'icon': 'Add',
			'color': 'success',
			'click': add_wave,
		},
		{
			'text': 'Delete All Waves',
			'icon': 'Remove',
			'color': 'danger',
			'click': func() -> void:
				_delete_all_waves(),
		},
	]

@export var btn_multiple_1: Array:
	get: return [
		{
			'text': 'Import Level',
			'icon': 'ArrowDown',
			'click': func() -> void:
				show_file_dialog(
					'Import Level',
					FileDialog.FILE_MODE_OPEN_FILE,
					import_level,
				),
		},
		{
			'text': 'Export Level',
			'icon': 'Save',
			'click': func() -> void:
				show_file_dialog(
					'Export Level',
					FileDialog.FILE_MODE_SAVE_FILE,
					export_level,
				),
		}
	]

var waves: Array[LevelEditorWave] = []
var _non_wave_child_added: bool = false
var _last_selected_wave_node: LevelEditorWave

func _ready() -> void:
	if Engine.is_editor_hint():
		EditorInterface.get_selection().selection_changed.connect(_on_selection_changed)

	child_order_changed.connect(_on_child_order_changed)
	child_entered_tree.connect(_on_child_entered_tree)

	for child_node in get_children():
		child_node.queue_free()

func _on_selection_changed() -> void:
	var selected_wave_nodes: Array[LevelEditorWave] = _get_selected_wave_nodes()

	if not _get_selected_nodes():
		return

	if selected_wave_nodes:
		for wave_node in _get_all_wave_nodes():
			var is_selected: bool = wave_node in selected_wave_nodes
			wave_node.visible = is_selected

	if _non_wave_child_added:
		_non_wave_child_added = false

		if not _last_selected_wave_node:
			var node := _get_selected_nodes()[0]
			_display_accept_dialog(
				'Attempted adding node \'%s\' without previously selecting a Wave node.\n
				Please select a scene tree before adding in nodes.' % [node.name]
			)
			node.queue_free()
		else:
			var selection: EditorSelection = EditorInterface.get_selection()
			var newly_added_node: Node = selection.get_selected_nodes()[0]
			newly_added_node.reparent(_last_selected_wave_node)
			selection.add_node(_last_selected_wave_node)

	if _get_selected_nodes().pop_back() is LevelEditor:
		_last_selected_wave_node = null
	
	if _get_selected_nodes().pop_back() is LevelEditorWave:
		_last_selected_wave_node = selected_wave_nodes.pop_back()

func _on_child_entered_tree(node: Node) -> void:
	if node is not LevelEditorWave:
		_non_wave_child_added = true

func _on_child_order_changed() -> void:
	waves = _get_all_wave_nodes()

func add_wave() -> LevelEditorWave:
	var wave := LevelEditorWave.new()
	add_child(wave)
	wave.owner = self
	wave.name = wave.name.replace('@Node2D@', 'Wave | ')
	wave.visible = false
	wave.wave_spawn_delay_sec = wave_spawn_delay_sec
	return wave

func show_file_dialog(
	title: String,
	file_mode: FileDialog.FileMode,
	on_select_callback: Callable,
) -> void:
	var file_dialog := FileDialog.new()
	file_dialog.file_mode = file_mode
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.size = DisplayServer.screen_get_size() * 0.3
	file_dialog.title = title
	file_dialog.filters = PackedStringArray(['*.json'])					# Allowed file extensions
	file_dialog.current_file = level_name.to_snake_case() + '.json'		# Suggested file name
	file_dialog.current_dir = _get_initial_file_dialog_dir.call()		# Initial directory
	file_dialog.file_selected.connect(on_select_callback)

	get_tree().root.add_child(file_dialog)
	file_dialog.popup_centered()

func import_level(file_path: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.READ)
	var level_data: Dictionary = JSON.parse_string(file.get_as_text())

	# cleanup before importing
	_delete_all_waves()

	var entity_refs: Array = _get_entity_refs()
	level_name = level_data['level_name']
	
	for wave_data: Dictionary in level_data['waves']:
		var wave: LevelEditorWave = add_wave()

		for entity_data: Dictionary in wave_data['entities']:
			var entity_scene_path: String
			for entity_ref: Dictionary in entity_refs:
				if entity_ref['id'] == entity_data['entity_id']:
					entity_scene_path = entity_ref['scene_path']

			var entity_instance: Entity = load(entity_scene_path).instantiate()
			# var entity_instance.position = entity['position']
			entity_instance.rotation = entity_data['rotation']

			wave.add_child(entity_instance)
			entity_instance.owner = wave
			print(entity_instance.name)

func export_level(file_path: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	var level_data: Dictionary = _get_level_data()
	file.store_line(JSON.stringify(level_data, '\t'))

	_display_accept_dialog('Successfully exported level \'%s\' to \'%s\'.' % [level_name, file_path], false)

func _get_level_data() -> Dictionary:
	var level_data: Dictionary = {}
	level_data['level_name'] = level_name
	level_data['waves'] = []

	var entity_refs: Array = _get_entity_refs()

	for wave_node in _get_all_wave_nodes():
		var wave_entry: Dictionary = {
			'spawn_delay': wave_node.wave_spawn_delay_sec,
			'entities': [],
		}
		for entity in wave_node.get_entity_nodes():
			var entity_id: String
			for entity_ref: Dictionary in entity_refs:
				if entity_ref['scene_path'] == entity.scene_file_path:
					entity_id = entity_ref['id']

			var entity_entry: Dictionary = {
				'entity_id': entity_id,
				'position': [
					entity.position.x,
					entity.position.y
				],
				'rotation': entity.rotation,
			}

			wave_entry['entities'].append(entity_entry)
		level_data['waves'].append(wave_entry)

	return level_data

func _get_all_wave_nodes() -> Array[LevelEditorWave]:
	# This can't be a simple .filter()
	# due to static typing array bs
	var wave_nodes: Array[LevelEditorWave] = []
	for node in get_children():
		if node is LevelEditorWave:
			wave_nodes.append(node)
	return wave_nodes

func _get_selected_wave_nodes() -> Array[LevelEditorWave]:
	var selected_wave_nodes: Array[LevelEditorWave] = []

	for node in _get_selected_nodes():
		if node is LevelEditorWave and node not in selected_wave_nodes:
			selected_wave_nodes.append(node)
			continue
	
		var ancestor: LevelEditorWave = _find_first_parent_of_type(node, LevelEditorWave)
		if ancestor and ancestor not in selected_wave_nodes:
			selected_wave_nodes.append(ancestor)

	return selected_wave_nodes

func _get_selected_nodes() -> Array[Node]:
	return EditorInterface.get_selection().get_selected_nodes()

func _display_accept_dialog(text: String, exclusive: bool = true) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = 'LevelEditor'
	dialog.dialog_text = text
	dialog.exclusive = exclusive
	dialog.canceled.connect(queue_free)
	get_tree().root.add_child(dialog)
	dialog.popup_centered()
	dialog.show()

func _find_first_parent_of_type(node: Node, parent_type: Variant, _recursion_attempt: int = 0) -> Node:
	var max_recursion_attempts := 5
	var parent := node.get_parent()

	if is_instance_of(parent, parent_type):
		return parent

	if _recursion_attempt >= max_recursion_attempts:
		return null

	return _find_first_parent_of_type(parent, parent_type, _recursion_attempt+1)

func _get_initial_file_dialog_dir() -> String:
	var config := ConfigFile.new()
	if config.load('user://level_editor.cfg') == OK:
		return config.get_value('Config', 'last_used_export_dir')

	# Fallback to user Desktop
	var drive_letter: String = OS.get_environment('windir').rstrip(':\\Windows')
	var username: String = OS.get_environment('USERNAME')
	return '%s:/Users/%s/Desktop' % [drive_letter, username]

func _delete_all_waves() -> void:
	for node in get_children():
		if node is LevelEditorWave:
			node.queue_free()

func _get_entity_refs() -> Array:
	return JSON.parse_string(FileAccess.open("res://entity_refs.json", FileAccess.READ).get_as_text())
