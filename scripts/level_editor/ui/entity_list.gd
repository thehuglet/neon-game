extends PanelContainer

const NEON_SPRITE_SCENE_PATH: String = 'res://scenes/components/neon_sprite.tscn'
const ENTITY_REGISTRY_PATH: String = 'res://resources/entity_registry.tres'

@onready var _grid_container: GridContainer = %GridContainer

func _ready() -> void:
	var current_slot_index: int = 0

	var entity_scene_paths: Array[String] = (ResourceLoader.load(ENTITY_REGISTRY_PATH) as EntityRegistry).registered_entities

	for path in entity_scene_paths:
		var scene: PackedScene = load(path)
		var scene_state: SceneState = scene.get_state()

		var slot: LevelEditorEntityListSlot = _grid_container.get_children() \
			.filter(func(node: Node) -> bool: return node is LevelEditorEntityListSlot)[current_slot_index]

		current_slot_index += 1

		slot._entity_scene_path = path
		slot.panel.mouse_filter = Control.MOUSE_FILTER_PASS

		for node_index in range(scene_state.get_node_count()):
			var node_at_index: PackedScene = scene_state.get_node_instance(node_index)

			if not node_at_index:
				continue

			if node_at_index.resource_path == NEON_SPRITE_SCENE_PATH:
				for property_index in range(scene_state.get_node_property_count(node_index)):
					var property_name: String = scene_state.get_node_property_name(node_index, property_index)
					var property_value: Variant = scene_state.get_node_property_value(node_index, property_index)

					match property_name:
						'base_texture':
							slot.neon_sprite.base_texture = property_value
						'glow_texture':
							slot.neon_sprite.glow_texture = property_value
						'color':
							slot.neon_sprite.color = property_value
						'sprite_scale':
							slot.neon_sprite.sprite_scale = property_value
						'color_on_base':
							slot.neon_sprite.color_on_base = property_value
						'rgb_boost_link':
							slot.neon_sprite.rgb_boost_link = property_value
						'base_rgb_boost':
							slot.neon_sprite.base_rgb_boost = property_value
						'glow_rgb_boost':
							slot.neon_sprite.glow_rgb_boost = property_value
						'alpha_boost_link':
							slot.neon_sprite.alpha_boost_link = property_value
						'base_alpha_boost':
							slot.neon_sprite.base_alpha_boost = property_value
						'glow_alpha_boost':
							slot.neon_sprite.glow_alpha_boost = property_value
