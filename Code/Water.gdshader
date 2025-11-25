shader_type canvas_item;

// Wave speed in X and Y directions
uniform float wave_speed_x : hint_range(0, 5) = 0.5;
uniform float wave_speed_y : hint_range(0, 5) = 0.3;

// Wave amplitude (how much the water moves)
uniform float wave_amplitude : hint_range(0, 50) = 5.0;

// Wave frequency (size of the chunks)
uniform float wave_frequency : hint_range(5, 100) = 20.0;

// Base water color (bright blue)
uniform vec4 water_color = vec4(0.23, 0.52, 1.0, 1.0);

void fragment() {
    vec2 uv = SCREEN_UV;

    // Chunky waves for pixel-art feel
    float wave_x = floor(sin((uv.x * wave_frequency) + TIME * wave_speed_x) * 4.0) / 4.0;
    float wave_y = floor(cos((uv.y * wave_frequency) + TIME * wave_speed_y) * 4.0) / 4.0;

    // Combine the waves
    float wave = wave_x + wave_y;

    // Brighter scaling
    wave = clamp(0.85 + 0.5 * wave, 0.0, 1.0);

    COLOR = water_color * wave;
}
