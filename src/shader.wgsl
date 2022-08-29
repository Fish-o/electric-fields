struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) color: vec3<f32>,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec3<f32>,
};

@vertex
fn vs_main(
    model: VertexInput,
) -> VertexOutput {
    var out: VertexOutput;
    out.color = model.color;
    out.clip_position = vec4<f32>(model.position, 1.0);
    return out;
}

// Fragment shader

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    var decay_factor = 0.05;
    var deadzone = 30.0;

    var all_emitters: array<vec3<f32>,2>;
    var emitter_amount = 2;
    all_emitters[0] = vec3<f32>(200.0, 200.0, 1000.0);
    all_emitters[1] = vec3<f32>(400.0, 400.0, 100.0);

    var field_strengths: array<vec2<f32>,2>;
    var max_strength: f32 = 0.0;
    var i: i32 = 0;
    loop {
        if (i >= emitter_amount) {break;}
        var emitter = all_emitters[i];
        var emitter_strength = emitter.z;
        var emitter_max_strength = emitter_strength / (deadzone * deadzone * decay_factor);
        if (emitter_max_strength > max_strength) {
            max_strength = emitter_max_strength;
        }
        var vec_from_emitter = in.clip_position.xy - emitter.xy;
        var e_normal = normalize(vec_from_emitter);
        var e_distance = length(vec_from_emitter);
        var e_strength = emitter_strength / (e_distance * e_distance * decay_factor);
        var e_total = e_normal * e_strength;
        field_strengths[i] = e_total;
        i++;
    }

    var total_field: vec2<f32> = vec2<f32>(0.0, 0.0);
    i = 0;
    loop {
        if (i >= emitter_amount) {break;}
        var field_strength = field_strengths[i];
        total_field = total_field + field_strength;
        i++;
    }
    var field_strength = length(total_field);
    var normalized_field_strength = (field_strength / max_strength) * 20.0;




    let color0 = vec3<f32>(0.0, 0.0, 0.0);
    let color1 = vec3<f32>(0.9, 0.0, 0.0);
    let color2 = vec3<f32>(1.0, 1.0, 0.0);
    let color3 = vec3<f32>(0.6, 0.6, 1.0);

    let stop1 = 0.1;
    let stop2 = 2.0;
    let end = 20.0;
    if (normalized_field_strength < stop1) {
        return vec4<f32>(color0 + (color1 - color0) * (normalized_field_strength * (1.0 / stop1)), 1.0);
    } else if (normalized_field_strength < stop2) {
        return vec4<f32>(color1 + (color2 - color1) * ((normalized_field_strength - stop1) / (stop2 - stop1)), 1.0);
    } else {
        return vec4<f32>(color2 + (color3 - color2) * ((normalized_field_strength - stop2 ) / (end - stop2)), 1.0);
    }
}

