shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled;

uniform vec4 glass_color : source_color = vec4(0.5, 0.8, 1.0, 0.3);
uniform float roughness : hint_range(0, 1) = 0.1;
uniform float refraction : hint_range(0, 1) = 0.05;
uniform float metallic : hint_range(0, 1) = 0.9;

void fragment() {
    ALBEDO = glass_color.rgb;
    ALPHA = glass_color.a;
    METALLIC = metallic;
    ROUGHNESS = roughness;
    SPECULAR = 0.5;
}