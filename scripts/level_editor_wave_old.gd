class_name LevelEditorWave
extends Node2D

@export_range(0.0, 60.0, 0.5) var wave_spawn_delay_sec: float

@export var btn_move_up: Dictionary:
	get: return {
		'text': 'Move Up     ',
		'icon': 'ArrowUp',
		'align': 'center',
		'click': func() -> void:
			get_parent().move_child(self, max(0, get_index()-1)),
	}

@export var btn_move_down: Dictionary:
	get: return {
		'text': 'Move Down',
		'icon': 'ArrowDown',
		'align': 'center',
		'click': func() -> void:
			get_parent().move_child(self, get_index()+1),
	}

func get_entity_nodes() -> Array[Entity]:
	var entity_nodes: Array[Entity] = []
	for node in get_children():
		if node is Entity:
			entity_nodes.append(node)
	return entity_nodes

@export var btn_delete: Dictionary:
	get: return {
		'text': 'Delete Wave',
		'icon': 'Remove',
		'color': 'danger',
		'click': func() -> void: queue_free(),
	}
