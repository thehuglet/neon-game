shader_type canvas_item;
render_mode blend_add;

#include "res://shaders/lib/hsv.gdshaderinc"

uniform vec4 u_color : source_color;
uniform float u_rgb_boost;
uniform float u_alpha_boost;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	// RGB Operations
	color.rgb = u_color.rgb * (1.0 + u_rgb_boost);
	color.a *= (1.0 + u_alpha_boost);

	COLOR = color;
}
