shader_type canvas_item;
render_mode unshaded; // consistent colors, no light needed

// ---- controls you can tweak in the inspector ----
uniform float intensity : hint_range(0.0, 1.0) = 0.75;     // how strong the sunset tint is
uniform float horizon_height : hint_range(0.0, 1.0) = 0.35; // where the horizon sits (UV.y)
uniform float horizon_softness : hint_range(0.001, 1.0) = 0.25;

// gradient colors (top -> horizon -> bottom)
uniform vec3 top_color     : source_color = vec3(0.99, 0.58, 0.37); // peachy orange
uniform vec3 horizon_color : source_color = vec3(0.98, 0.32, 0.21); // deep orange-red
uniform vec3 bottom_color  : source_color = vec3(0.08, 0.02, 0.12); // dusk purple

// sun glow
uniform vec2  sun_pos      = vec2(0.5, 0.35); // in UV space (0..1)
uniform float sun_radius   : hint_range(0.0, 1.0) = 0.18;
uniform float sun_softness : hint_range(0.0, 1.0) = 0.55;
uniform vec3  sun_color    : source_color = vec3(1.00, 0.78, 0.45);

// optional vignette
uniform float vignette_strength  : hint_range(0.0, 1.0) = 0.35;
uniform float vignette_roundness : hint_range(0.5, 4.0) = 1.5;

vec3 sunset_gradient(float y) {
    // mix bottom->horizon up to horizon_height, then horizon->top above it
    float low_t  = smoothstep(0.0,     horizon_height, y);
    float high_t = smoothstep(horizon_height, 1.0,     y);

    vec3 low_mix  = mix(bottom_color,  horizon_color, low_t);
    vec3 high_mix = mix(horizon_color, top_color,     high_t);

    // blend those two around the horizon for a soft transition
    float h = smoothstep(horizon_height - horizon_softness,
                         horizon_height + horizon_softness, y);
    return mix(low_mix, high_mix, h);
}

void fragment() {
    vec4 src = texture(TEXTURE, UV);

    // base gradient tint
    vec3 grad = sunset_gradient(UV.y);
    vec3 col  = mix(src.rgb, grad, intensity);

    // soft haze centered on the horizon (a little atmospheric scatter)
    float hz = exp(-pow((UV.y - horizon_height) / max(0.0001, horizon_softness), 2.0));
    col = mix(col, mix(horizon_color, vec3(1.0), 0.5), hz * 0.25 * intensity);

    // sun disk + glow
    float d = distance(UV, sun_pos);
    // inner disk
    float sun_disk = smoothstep(sun_radius, sun_radius * 0.85, d);
    // outer glow
    float sun_glow = smoothstep(sun_radius * (1.0 + sun_softness), sun_radius, d);
    col += sun_color * (sun_glow * 0.55 + sun_disk * 0.35) * intensity;

    // gentle vignette
    vec2 p = UV * 2.0 - 1.0;
    float r = length(p * vec2(1.0, 1.0 / vignette_roundness));
    float vig = 1.0 - clamp(pow(r, 1.5), 0.0, 1.0);
    col *= mix(1.0, vig, vignette_strength);

    COLOR = vec4(col, src.a);
}
