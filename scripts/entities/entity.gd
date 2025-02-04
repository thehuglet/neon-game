class_name Entity
extends CharacterBody2D

@export var stats: EntityStats
var is_despawning: bool = false
@onready var movement: EntityMovement = get_children_by_type(EntityMovement).pop_front()

# This is done to avoid overriding _ready()
# and having to do base() call bs
@warning_ignore('unused_private_class_variable')
@onready var __ := ready.connect(func() -> void:
	stats = stats.duplicate()

	if movement:
		EntityMovementHandler.register_entity(self)
)

func despawn() -> void:
	is_despawning = true

	var despawn_timer := Timer.new()
	despawn_timer.autostart = true
	despawn_timer.one_shot = true
	despawn_timer.wait_time = 3.0
	despawn_timer.timeout.connect(func() -> void: queue_free())
	add_child(despawn_timer)

func get_children_by_type(data_type: Variant) -> Array:
	return get_children() \
		.filter(func(child_node: Node) -> bool: return is_instance_of(child_node, data_type))
