shader_type canvas_item;
render_mode blend_add;

uniform vec4 u_color : source_color;
uniform vec3 u_final_tint : source_color;
uniform float u_final_alpha;
uniform float u_rgb_boost;
uniform float u_alpha_boost;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	// RGB Operations
	color.rgb = u_color.rgb * (1.0 + u_rgb_boost);
	color.a *= (1.0 + u_alpha_boost);
	
	color.rgb *= u_final_tint;
	color.a *= u_final_alpha;

	COLOR = color;
}
