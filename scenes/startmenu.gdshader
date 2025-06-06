shader_type canvas_item;

uniform float time;
uniform float speed = 0.4;       // 🐢 slooooow
uniform float strength = 0.0015; // 🧘‍♂️ barely wavy

void fragment() {
    vec2 uv = UV;

    // Calm, subtle shimmer
    uv.y += sin(uv.x * 3.0 + time * speed) * strength;
    uv.x += cos(uv.y * 1.5 + time * speed * 0.5) * strength * 0.5;

    COLOR = texture(TEXTURE, uv);
}
