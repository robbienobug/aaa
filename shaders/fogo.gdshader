shader_type spatial;
render_mode unshaded, blend_add;

uniform sampler2D noise_texture : source_color;
uniform float speed = 2.0;
uniform float noise_strength = 0.3;
uniform vec3 flame_color_1 : source_color = vec3(1.0, 0.5, 0.1);
uniform vec3 flame_color_2 : source_color = vec3(1.0, 0.9, 0.3);

void fragment() {
    // Coordenadas UV com animação
    vec2 uv = UV;

    // Multiplos layers de ruído para aparência mais orgânica
    float noise1 = texture(noise_texture, uv * vec2(1.0, 2.0) + vec2(0.0, TIME * -speed)).r;
    float noise2 = texture(noise_texture, uv * vec2(2.0, 3.0) + vec2(0.5, TIME * -speed * 0.7)).r;
    float noise3 = texture(noise_texture, uv * vec2(0.5, 4.0) + vec2(0.2, TIME * -speed * 1.3)).r;

    // Combinação de ruídos
    float combined_noise = (noise1 * 0.5 + noise2 * 0.3 + noise3 * 0.2);

    // Forma da chama (mais intensa no centro)
    float flame_shape = 1.0 - uv.y;
    flame_shape *= 1.0 - abs(uv.x - 0.5) * 2.0; // Forma de cone

    // Valor final da chama
    float flame_value = combined_noise * flame_shape;
    flame_value = clamp(flame_value * 2.0, 0.0, 1.0);

    // Cor com gradiente
    vec3 color = mix(flame_color_1, flame_color_2, uv.y);

    // Adicionar brilho no centro
    float center_glow = 1.0 - abs(uv.x - 0.5) * 3.0;
    center_glow = max(0.0, center_glow);

    // Saída final

    ALBEDO = color * flame_value * (1.0 + center_glow);
    EMISSION = ALBEDO * 3.0;
    ALPHA = flame_value;
}