shader_type spatial;

uniform sampler2D albedo_texture : source_color;
uniform vec2 uv_offset = vec2(0.0);

void fragment() {
	vec2 modified_uv = UV + uv_offset;
	vec4 texture_color = texture(albedo_texture, modified_uv);
	ALBEDO = texture_color.rgb;

}