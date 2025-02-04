@tool
class_name EntityRegistrar
extends Node

const NODE_NAME = 'EntityRegistrar'

@export var btn_register_toggle: Dictionary:
	get:
		is_registered = is_entity_registered(get_entity())
		return {
			'text': 'Unregister Entity' if is_registered else 'Register Entity',
			'icon': 'Remove' if is_registered else 'Add',
			'color': 'danger' if is_registered else 'success',
			'click': func() -> bool:
				is_registered = is_entity_registered(get_entity())

				var entity_registry: EntityRegistry = get_entity_registry()
				var entity_scene_path: String = get_entity().scene_file_path

				if is_registered:
					entity_registry.registered_entities.erase(entity_scene_path)
					name = NODE_NAME
				else:
					entity_registry.registered_entities.append(entity_scene_path)
					name = NODE_NAME + ' (Registered)'

				ResourceSaver.save(entity_registry)
				return true;
	}

@onready var _entity_registry_path: String = 'res://resources/entity_registry.tres'
var is_registered: bool

func get_entity() -> Entity:
	var entity: Node = Utils.find_first_parent_of_type(self, Entity)

	if not entity is Entity:
		push_error('\'EntityRegistrar\' is not connected to a valid \'Entity\' parent!')

	return entity as Entity

func get_entity_registry() -> EntityRegistry:
	return ResourceLoader.load(_entity_registry_path)

func is_entity_registered(entity: Entity) -> bool: 
	return entity.scene_file_path in get_entity_registry().registered_entities
