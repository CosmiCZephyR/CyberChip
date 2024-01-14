shader_type canvas_item;

uniform vec4 color: source_color;

void fragment() {
    COLOR.rgb = mix(COLOR.rgb, color.rgb, clamp(0.8 * cos(cos(TIME)), 0.2, 1.0));
}