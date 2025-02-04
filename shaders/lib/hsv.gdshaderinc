// [0] Hue; [1] Saturation; [2] Brightness;

vec4 hsv2rgb(vec4 rgb_color) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(rgb_color.xxx + K.xyz) * 6.0 - K.www);
	return vec4(rgb_color.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), rgb_color.y), rgb_color.a);
}

vec4 rgb2hsv(vec4 hsv_color) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(hsv_color.bg, K.wz), vec4(hsv_color.gb, K.xy), step(hsv_color.b, hsv_color.g));
	vec4 q = mix(vec4(p.xyw, hsv_color.r), vec4(hsv_color.r, p.yzx), step(p.x, hsv_color.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec4(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x, hsv_color.a);
}
