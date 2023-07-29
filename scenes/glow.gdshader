shader_type canvas_item;

uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;
uniform float threshold;
uniform float intensity;
uniform float opacity;
uniform vec4 glow_color : source_color;

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);
	
	float distance_to = length(pixel_color - color1);
	
	float distance_second = length(pixel_color - color2);
	
	vec4 modified_glow_color = glow_color;
	
	modified_glow_color.a = opacity;
	
	if (distance_to < threshold || distance_second < threshold) {
		COLOR = mix(pixel_color, modified_glow_color * intensity, modified_glow_color.a);
	}
	else {
		COLOR = pixel_color;
	}
}