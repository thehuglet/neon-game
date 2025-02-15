extends Node

# Level structure:
# 	{ 
#		"level_name": "LEVEL_NAME",
#		"waves":
#		[
#			"delay_seconds": 2.0,
#			"enemies": [
#				{
#					"enemy_scene_path": "GODOT_ENTITY_PATH",
#					"position": [0.0, 0.0],
#					"rotation": 0.0
#				}
#			]
#		]
#	}

func load_level(level: Dictionary) -> void:
	print(level)

