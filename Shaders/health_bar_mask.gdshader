shader_type canvas_item;

uniform sampler2D mask;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float m = texture(mask, UV).r;
	COLOR = col * m;
}
