extends Node

var active_entities: Array[Entity] = []

func _process(delta: float) -> void:
	for i in range(active_entities.size() - 1, -1, -1):
		var entity: Entity = active_entities[i]
		
		if entity == null or entity.is_despawning:
			active_entities.remove_at(i)
			continue
	
		entity.position += entity.movement.calculate_position_offset(
			delta,
			entity.position,
			entity.stats.movement_speed,
		)

func register_entity(entity: Entity) -> void:
	active_entities.append(entity)
