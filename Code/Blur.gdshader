shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 1.0;

float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // --- Massive UV distortion ---
    float wave1 = sin(UV.y * 40.0 + TIME * 6.0) * 0.03 * intensity;
    float wave2 = cos(UV.x * 60.0 + TIME * 4.0) * 0.03 * intensity;

    float swirl = sin((UV.x + UV.y) * 50.0 + TIME * 5.0) * 0.05 * intensity;

    vec2 distorted_uv = UV;
    distorted_uv += vec2(wave1 + swirl, wave2 - swirl);

    // Pixelation
    float pix = mix(1.0, 40.0, intensity);
    distorted_uv = floor(distorted_uv * pix) / pix;

    // Noise-based displacement
    float noise1 = rand(UV * 100.0 + TIME) * 0.05 * intensity;
    float noise2 = rand(UV * 200.0 - TIME) * 0.05 * intensity;

    distorted_uv += vec2(noise1, noise2);

    // Base sample
    vec4 base = texture(TEXTURE, distorted_uv);

    // Chaotic color scrambling
    float r = rand(distorted_uv * 10.0 + TIME) * intensity;
    float g = rand(distorted_uv * 20.0 - TIME) * intensity;
    float b = rand(distorted_uv * 30.0 + TIME * 0.3) * intensity;

    vec3 scrambled = vec3(
        base.r * 0.15 + g + noise1,
        base.g * 0.15 + b + noise2,
        base.b * 0.15 + r
    );

    // -------- DARKEN EVERYTHING ---------
    // Tight darkness multiplier
    float dark_mult = mix(1.0, 0.15, intensity);
    scrambled *= dark_mult;

    // Shadow noise overlay (random dark patches)
    float shadow = rand(UV * 300.0 + TIME * 0.5);
    shadow = pow(shadow, mix(2.0, 8.0, intensity)); // stronger at high intensity
    scrambled *= shadow;

    // Black vignette to hide edges
    float dx = abs(UV.x - 0.5);
    float dy = abs(UV.y - 0.5);
    float vig = 1.0 - smoothstep(0.2, 0.6, sqrt(dx*dx + dy*dy));
    scrambled *= mix(1.0, vig, intensity);

    // Clamp final
    scrambled = clamp(scrambled, 0.0, 1.0);

    COLOR = vec4(scrambled, base.a);
}
