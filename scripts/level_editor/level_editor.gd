class_name LevelEditor
extends Node2D

@onready var _save_level_button: Button = %SaveLevelButton
@onready var _wave_incr_button: Button = %WaveIncrementButton
@onready var _wave_decr_button: Button = %WaveDecrementButton
@onready var _wave_number: Label = %WaveNumber
@onready var _wave_container: Node2D = %EntityWaveContainer

var waves: Array[LevelEditorEntityWave] = []
var selected_wave_index: int = 0
var waves_with_contents: Array[int] = []

func _ready() -> void:
	_wave_number.text = '1'
	add_wave()
	waves[0].is_wave_selected = true

	_save_level_button.pressed.connect(func() -> void:
		show_file_dialog(
			'Save Level',
			'my_level',
			FileDialog.FileMode.FILE_MODE_SAVE_FILE,
			on_save_level,
		)
	)
	_wave_incr_button.pressed.connect(func() -> void:
		selected_wave_index += 1

		if len(waves) == selected_wave_index:
			add_wave()
		
		_wave_number.text = str(selected_wave_index + 1)
		SignalBus.level_editor_select_wave.emit(selected_wave_index)
	)
	_wave_decr_button.pressed.connect(func() -> void:
		if selected_wave_index == 0:
			return

		selected_wave_index -= 1

		if not waves_with_contents or selected_wave_index > waves_with_contents[-1]:
			remove_last_wave()

		_wave_number.text = str(selected_wave_index + 1)
		SignalBus.level_editor_select_wave.emit(selected_wave_index)
	)

	SignalBus.level_editor_add_entity.connect(_on_add_entity)

func _on_add_entity(pos: Vector2, old_neon_sprite: NeonSprite, entity_scene_path: String) -> void:
	var neon_sprite: NeonSprite = old_neon_sprite.duplicate()
	neon_sprite.position = pos
	neon_sprite._base_sprite.material = old_neon_sprite._base_sprite.material.duplicate()
	neon_sprite._glow_sprite.material = old_neon_sprite._glow_sprite.material.duplicate()

	var selected_wave: LevelEditorEntityWave = waves[selected_wave_index]
	selected_wave.add_entity(pos, neon_sprite, entity_scene_path)

	if selected_wave_index not in waves_with_contents:
		waves_with_contents.append(selected_wave_index)
		waves_with_contents.sort()

func on_save_level(file_path: String) -> void:
	var config := ConfigFile.new()

	var file_name_length: int = file_path.split('/')[-1].length()
	var save_dir: String = file_path.left(file_path.length() - file_name_length)

	config.set_value('Config', 'last_used_save_level_dir', save_dir)
	config.save('user://level_editor.cfg')

	# Jak amys to zakoduje? nie wiem, bedzie to wymagalo magii XDD
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	var level_data: Dictionary = get_level_data()
	file.store_line(JSON.stringify(level_data, '\t'))

	print(level_data)

func get_level_data() -> Dictionary:
	var level: Dictionary = {}

	level['level_name'] = 'TEMP_LEVEL_NAME'
	# level['waves'] = []

	return {}

func add_wave() -> void:
	var wave: LevelEditorEntityWave = LevelEditorEntityWave.new()
	wave.wave_index = selected_wave_index
	waves.append(wave)
	_wave_container.add_child(wave)

func remove_last_wave() -> void:
	_wave_container.remove_child(_wave_container.get_children().pop_back())
	waves.pop_back()

func remove_wave_at_index(index: int) -> void:
	pass

func show_file_dialog(
	title: String,
	file_name: String,
	file_mode: FileDialog.FileMode,
	on_select_callback: Callable
) -> void:
	var file_dialog := FileDialog.new()
	file_dialog.file_mode = file_mode
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.size = DisplayServer.screen_get_size() * 0.3
	file_dialog.title = title
	file_dialog.filters = PackedStringArray(['*.json'])				# Allowed file extensions
	file_dialog.current_file = file_name + '.json'					# Suggested file name
	file_dialog.current_dir = _get_initial_file_dialog_dir.call()	# Initial directory
	file_dialog.file_selected.connect(on_select_callback)

	get_tree().root.add_child(file_dialog)
	file_dialog.popup_centered()

func _get_initial_file_dialog_dir() -> String:
	var config := ConfigFile.new()
	if config.load('user://level_editor.cfg') == OK:
		return config.get_value('Config', 'last_used_save_level_dir')

	# Fallback to user Desktop
	var drive_letter: String = OS.get_environment('windir').rstrip(':\\Windows')
	var username: String = OS.get_environment('USERNAME')
	return '%s:/Users/%s/Desktop' % [drive_letter, username]
