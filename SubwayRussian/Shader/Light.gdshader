shader_type spatial;
render_mode unshaded, ambient_light_disabled;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 10.0) = 1.0;
uniform float glow_falloff : hint_range(0.1, 3.0) = 1.0;
uniform bool use_distance_falloff = true;

void fragment() {
    ALBEDO = glow_color.rgb;
    EMISSION = glow_color.rgb * glow_intensity;
    ALPHA = glow_color.a;

    if (use_distance_falloff) {
        float falloff = 1.0 - smoothstep(0.0, 1.0, length(VIEW));
        if (glow_falloff == 1.0) {
            EMISSION *= falloff;
        } else if (glow_falloff == 2.0) {
            EMISSION *= falloff * falloff;
        } else {
            EMISSION *= pow(falloff, glow_falloff);
        }
    }
}