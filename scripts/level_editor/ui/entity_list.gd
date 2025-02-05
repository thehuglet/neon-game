extends PanelContainer

const NEON_SPRITE_SCENE_PATH: String = 'res://scenes/components/neon_sprite.tscn'
const ENTITY_REGISTRY_PATH: String = 'res://resources/entity_registry.tres'

const EXCLUDED_ENTITY_SCENES: Array[String] = [
	'res://scenes/entities/player.tscn'
]

@onready var _grid_container: GridContainer = %GridContainer

func _ready() -> void:
	var entity_registry: EntityRegistry = ResourceLoader.load(ENTITY_REGISTRY_PATH) as EntityRegistry
	if not entity_registry:
		push_error('Failed to load entity registry.')
		return

	var entity_scene_paths: Array[String] = entity_registry.registered_entities
	var slots: Array[LevelEditorEntityListSlot] = _get_slots()

	for excluded_entity_scene in EXCLUDED_ENTITY_SCENES:
		entity_scene_paths.erase(excluded_entity_scene)

	for i: int in min(entity_scene_paths.size(), slots.size()):
		_initialize_slot(slots[i], entity_scene_paths[i])

func _get_slots() -> Array[LevelEditorEntityListSlot]:
	# workaround for a static-typing godot bug
	var new_array: Array[LevelEditorEntityListSlot] = []
	var slots := _grid_container.get_children() \
		.filter(func(node: Node) -> bool: return node is LevelEditorEntityListSlot)
	new_array.append_array(slots)
	return new_array

func _initialize_slot(slot: LevelEditorEntityListSlot, entity_scene_path: String) -> void:
	var scene: PackedScene = load(entity_scene_path)
	if not scene:
		push_error('Failed to load scene at path: ' + entity_scene_path)
		return
	
	var scene_state: SceneState = scene.get_state()
	slot._entity_scene_path = entity_scene_path
	slot.panel.mouse_filter = Control.MOUSE_FILTER_PASS

	_apply_neon_sprite_properties(slot, scene_state)

func _apply_neon_sprite_properties(slot: LevelEditorEntityListSlot, scene_state: SceneState) -> void:
	for node_index in range(scene_state.get_node_count()):
		var node_at_index: PackedScene = scene_state.get_node_instance(node_index)
		if not node_at_index or node_at_index.resource_path != NEON_SPRITE_SCENE_PATH:
			continue

		for property_index in range(scene_state.get_node_property_count(node_index)):
			var property_name: String = scene_state.get_node_property_name(node_index, property_index)
			var property_value: Variant = scene_state.get_node_property_value(node_index, property_index)

			match property_name:
				'base_texture': slot.neon_sprite.base_texture = property_value
				'glow_texture': slot.neon_sprite.glow_texture = property_value
				'color': slot.neon_sprite.color = property_value
				'sprite_scale': slot.neon_sprite.sprite_scale = property_value
				'color_on_base': slot.neon_sprite.color_on_base = property_value
				'rgb_boost_link': slot.neon_sprite.rgb_boost_link = property_value
				'base_rgb_boost': slot.neon_sprite.base_rgb_boost = property_value
				'glow_rgb_boost': slot.neon_sprite.glow_rgb_boost = property_value
				'alpha_boost_link': slot.neon_sprite.alpha_boost_link = property_value
				'base_alpha_boost': slot.neon_sprite.base_alpha_boost = property_value
				'glow_alpha_boost': slot.neon_sprite.glow_alpha_boost = property_value
