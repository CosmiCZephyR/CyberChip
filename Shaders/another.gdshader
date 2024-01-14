shader_type canvas_item;

vec3 palette( float t) {
	vec3 a = vec3(0.5, 0.5, 0.5);
	vec3 b = vec3(0.75, 0.75, 0.75);
	vec3 c = vec3(1.0, 1.0, 1.0);
	vec3 d = vec3(0.0, 0.333, 0.666);
	
	return a + b * cos( 6.28318*(c*t+d) );
}

void fragment() {
	vec2 uv = UV;
	vec2 center = vec2(25);
	uv = (UV - center);
	
	float d = length(uv) / 5.0;
	vec3 col = palette(d + TIME);
	
	d = sin(d * 8.0 - TIME) / 8.0;
	d = abs(d);
	
	d = 0.02 / d;
	
	col *= d;
	
	COLOR = vec4(col, 1.0);
}
