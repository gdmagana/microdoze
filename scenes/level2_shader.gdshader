shader_type canvas_item;

uniform float time;
uniform float amplitude = 5.0;
uniform float frequency = 10.0;

void fragment() {
    vec2 uv = UV;
    uv.y += sin(uv.x * frequency + time) * (amplitude / 100.0);
    COLOR = texture(TEXTURE, uv);
}
