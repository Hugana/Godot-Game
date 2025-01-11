/*
Simplified CRT shader with minimal effects and green tint.
*/

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

uniform vec2 resolution = vec2(320.0, 180.0);

uniform float scan_line_amount :hint_range(0.0, 1.0) = 0.1;
uniform float scan_line_strength :hint_range(-12.0, -1.0) = -2.0;
uniform float warp_amount :hint_range(0.0, 5.0) = 0.005;
uniform float noise_amount :hint_range(0.0, 0.3) = 0.002;
uniform float grille_amount :hint_range(0.0, 1.0) = 0.01;
uniform float vignette_amount :hint_range(0.0, 2.0) = 0.1;
uniform float vignette_intensity :hint_range(0.0, 1.0) = 0.1;
uniform float aberation_amount :hint_range(0.0, 1.0) = 0.05;
uniform float roll_line_amount :hint_range(0.0, 1.0) = 0.02;
uniform float roll_speed :hint_range(-8.0, 8.0) = 0.3;

float random(vec2 uv) {
	return fract(cos(uv.x * 83.4827 + uv.y * 92.2842) * 43758.5453123);
}

vec3 fetch_pixel(vec2 uv, vec2 off) {
	vec2 pos = floor(uv * resolution + off) / resolution + vec2(0.5) / resolution;

	float noise = 0.0;
	if (noise_amount > 0.0) {
		noise = random(pos + fract(TIME)) * noise_amount;
	}

	if (max(abs(pos.x - 0.5), abs(pos.y - 0.5)) > 0.5) {
		return vec3(0.0, 0.0, 0.0);
	}

	vec3 clr = texture(SCREEN_TEXTURE, pos, -16.0).rgb + noise;
	return clr;
}

vec2 Dist(vec2 pos) {
	pos = pos * resolution;
	return -((pos - floor(pos)) - vec2(0.5));
}

float Gaus(float pos, float scale) { return exp2(scale * pos * pos); }

vec3 Tri(vec2 pos) {
	vec3 clr = fetch_pixel(pos, vec2(0.0));
	if (scan_line_amount > 0.0) {
		vec3 a = fetch_pixel(pos, vec2(0.0, -1.0));
		vec3 b = fetch_pixel(pos, vec2(0.0, 0.0));
		vec3 c = fetch_pixel(pos, vec2(0.0, 1.0));

		float wa = Gaus(Dist(pos).y - 1.0, scan_line_strength);
		float wb = Gaus(Dist(pos).y, scan_line_strength);
		float wc = Gaus(Dist(pos).y + 1.0, scan_line_strength);

		vec3 scanlines = a * wa + b * wb + c * wc;
		clr = mix(clr, scanlines, scan_line_amount);
	}
	return clr;
}

vec2 warp(vec2 uv) {
	vec2 delta = uv - 0.5;
	float delta2 = dot(delta.xy, delta.xy);
	float delta4 = delta2 * delta2;
	float delta_offset = delta4 * warp_amount;
	return uv + delta * delta_offset;
}

float vignette(vec2 uv) {
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 15.0;
	return pow(vignette, vignette_intensity * vignette_amount);
}

float roll_line(vec2 uv) {
	float x = uv.y * 3.0 - TIME * roll_speed;
	float f = cos(x) * cos(x * 2.35 + 1.1) * cos(x * 4.45 + 2.3);
	float roll_line = smoothstep(0.5, 0.9, f);
	return roll_line * roll_line_amount;
}

void fragment() {
	vec2 pix = FRAGCOORD.xy;
	vec2 pos = warp(SCREEN_UV);

	float line = 0.0;
	if (roll_line_amount > 0.0) {
		line = roll_line(pos);
	}

	vec3 clr = Tri(pos);
	if (aberation_amount > 0.0) {
		float chromatic = aberation_amount + line * 0.1;
		vec2 chromatic_offset = vec2(chromatic) / resolution;
		float r = Tri(pos - chromatic_offset).r;
		float g = Tri(pos).g;
		float b = Tri(pos + chromatic_offset).b;
		clr = vec3(r, g, b);
	}

	if (grille_amount > 0.0) clr *= vec3(1.0 - grille_amount, 1.0, 1.0 - grille_amount);
	if (vignette_amount > 0.0) clr *= vignette(pos);

	// Apply green tint
	COLOR.rgb = clr * vec3(0.8, 1.0, 0.8); // Slightly green tint
	COLOR.a = 1.0;
}
