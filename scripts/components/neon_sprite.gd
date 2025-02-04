@tool
class_name NeonSprite
extends Node2D

@export var base_texture: Texture2D:
	set(value):
		base_texture = value
		_base_sprite.texture = value
@export var glow_texture: Texture2D:
	set(value):
		glow_texture = value
		_glow_sprite.texture = value
@export var sprite_scale: float:
	set(value):
		sprite_scale = value
		if _base_sprite && _glow_sprite:
			_base_sprite.scale = Vector2(value, value)
			_glow_sprite.scale = Vector2(value, value)
@export var color: Color:
	set(value):
		color = value
		_set_shader_uniform(_glow_sprite, 'u_color', value)
		if color_on_base:
			_set_shader_uniform(_base_sprite, 'u_color', value)
@export var color_on_base: bool:
	set(value):
		color_on_base = value
		if value:
			_set_shader_uniform(_base_sprite, 'u_color', color)
		else:
			_set_shader_uniform(_base_sprite, 'u_color', Color.WHITE)
@export_group('RGB Boost')
@export var rgb_boost_link: bool:
	set(value):
		rgb_boost_link = value
@export_range(0.0, 20.0, 0.1) var base_rgb_boost: float:
	set(value):
		base_rgb_boost = value
		_set_shader_uniform(_base_sprite, 'u_rgb_boost', value)
		if _skip_next_link:
			_skip_next_link = false
		elif rgb_boost_link:
			_skip_next_link = true
			glow_rgb_boost = value
@export_range(0.0, 20.0, 0.1) var glow_rgb_boost: float:
	set(value):
		glow_rgb_boost = value
		_set_shader_uniform(_glow_sprite, 'u_rgb_boost', value)
		if _skip_next_link:
			_skip_next_link = false
		elif rgb_boost_link:
			_skip_next_link = true
			base_rgb_boost = value
@export_group('Alpha Boost')
@export var alpha_boost_link: bool:
	set(value):
		alpha_boost_link = value
@export_range(0.0, 20.0, 0.1) var base_alpha_boost: float:
	set(value):
		base_alpha_boost = value
		_set_shader_uniform(_base_sprite, 'u_alpha_boost', value)
		if _skip_next_link:
			_skip_next_link = false
		elif alpha_boost_link:
			_skip_next_link = true
			glow_alpha_boost = value
@export_range(0.0, 20.0, 0.1) var glow_alpha_boost: float:
	set(value):
		glow_alpha_boost = value
		_set_shader_uniform(_glow_sprite, 'u_alpha_boost', value)
		if _skip_next_link:
			_skip_next_link = false
		elif alpha_boost_link:
			_skip_next_link = true
			base_alpha_boost = value
@export_group('Private')
@export var _base_sprite: Sprite2D
@export var _glow_sprite: Sprite2D

var _skip_next_link: bool = false

func _set_shader_uniform(node: Sprite2D, uniform_name: String, value: Variant) -> void:
	if node:
		(node.material as ShaderMaterial).set_shader_parameter(uniform_name, value)
