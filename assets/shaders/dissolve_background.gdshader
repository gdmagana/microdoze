shader_type canvas_item;

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform texture2D noise_texture : hint_default_white;
uniform texture2D normal_background : hint_default_white;
uniform texture2D psychedelic_background : hint_default_white;
uniform float noise_scale : hint_range(0.1, 10.0) = 1.0;

void fragment() {
    vec2 noise_uv = UV * noise_scale;
    float noise = texture(noise_texture, noise_uv).r;
    
    // Sample both backgrounds
    vec4 normal_color = texture(normal_background, UV);
    vec4 psychedelic_color = texture(psychedelic_background, UV);
    
    // Create dissolve mask based on noise and dissolve amount
    float dissolve_mask = step(noise, dissolve_amount);
    
    // Mix the two backgrounds based on the dissolve mask
    COLOR = mix(normal_color, psychedelic_color, dissolve_mask);
}
