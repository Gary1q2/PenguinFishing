shader_type canvas_item;
render_mode blend_mix, unshaded;

#ifdef GL_ES
precision highp float;
#endif

uniform float transparency : hint_range(0, 1) = 1.0;

uniform vec4 color0 : source_color;
uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;
uniform vec4 color3 : source_color;
uniform vec4 color4 : source_color;
uniform vec4 color5 : source_color;

uniform vec2 Direction1 = vec2(1, 0);
uniform vec2 Direction2 = vec2(1, 1);
uniform float Speed1 = 0.08;
uniform float Speed2 = 0.08;
uniform sampler2D noise : repeat_enable;
uniform int pixel_size;

uniform float slant_amount : hint_range(-0.5, 0.5) = 0.2;
uniform float top_shrink : hint_range(0.0, 10) = 0.2;

// ----------------------------
// Utility functions
// ----------------------------
vec4 get_pixelated_moving_colors(vec2 uv, vec2 direction, float speed, float t) {
    speed = speed / 1000.0;

    // Move UV and wrap to 0..1 to prevent stretching at edges
    vec2 moving_uv = uv + direction * t * speed;
    moving_uv = fract(moving_uv); // wrap UV

    // Pixelate
    vec2 pixel_uv = round(moving_uv * float(pixel_size) - 0.5) / float(pixel_size) + 0.5/float(pixel_size);
    return texture(noise, pixel_uv);
}

bool is_in_threshold(vec4 old_color, float threshold_low, float threshold_hi){
    float sum = old_color.r + old_color.g + old_color.b;
    return (threshold_low <= sum && sum < threshold_hi);
}

vec4 smooth_extreme_colors(vec4 color) {
    float threshold_1 = 1.7;
    float threshold_2 = 1.9;
    float threshold_3 = 2.2;
    float threshold_4 = 2.25;
    float threshold_5 = 2.3;

    if (is_in_threshold(color, 0.0, threshold_1))      return color0;
    else if (is_in_threshold(color, threshold_1, threshold_2)) return color1;
    else if (is_in_threshold(color, threshold_2, threshold_3)) return color2;
    else if (is_in_threshold(color, threshold_3, threshold_4)) return color3;
    else if (is_in_threshold(color, threshold_4, threshold_5)) return color4;
    else if (is_in_threshold(color, threshold_5, 3.0)) return color5;

    return color;
}

// ----------------------------
// Main fragment
// ----------------------------
void fragment() {
    float t = mod(TIME, 1000.0); // clamp TIME to prevent accumulation errors

    // --- Apply isometric slant ---
    vec2 slanted_uv = UV;
    float center_dist = UV.x - 0.5;
    float shrink_factor = (1.0 - UV.y) * top_shrink;
    slanted_uv.x += center_dist * shrink_factor;

    // --- Get moving pixelated colors ---
    vec4 pixelated_color = 0.5 * get_pixelated_moving_colors(slanted_uv, Direction1, Speed1, t);
    pixelated_color += 0.5 * get_pixelated_moving_colors(slanted_uv, Direction2, Speed2, t);

    // --- Smooth colors ---
    vec4 smoothed_color = smooth_extreme_colors(pixelated_color);

    COLOR = smoothed_color * transparency;
}
