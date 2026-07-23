shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 10.0) = 4.0;
uniform float desaturate : hint_range(0.0, 1.0) = 0.5;
uniform float darken : hint_range(0.0, 1.0) = 0.3;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	// Rozmycie gaussowskie (uproszczone)
	vec2 tex_size = 1.0 / vec2(textureSize(TEXTURE, 0));
	float blur = blur_amount;
	
	vec4 blurred = vec4(0.0);
	float total = 0.0;
	
	// 5x5 kernel dla efektu bokeh
	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			vec2 offset = vec2(float(x), float(y)) * tex_size * blur;
			float weight = exp(-float(x*x + y*y) / 4.0);
			blurred += texture(TEXTURE, UV + offset) * weight;
			total += weight;
		}
	}
	blurred /= total;
	
	// Desaturacja
	vec3 gray = vec3(dot(blurred.rgb, vec3(0.299, 0.587, 0.114)));
	blurred.rgb = mix(blurred.rgb, gray, desaturate);
	
	// Przyciemnienie
	blurred.rgb *= (1.0 - darken);
	
	COLOR = blurred;
}
