package window

quit :: proc() {
    running = false
}

// converts a point in screen space to a point in ndc (opengl space)
ss_to_ndc :: proc(x,y: f32) -> (f32,f32) {
    return ((f32(x) / f32(size_width)) *2 -1), -((f32(y) / f32(size_height)) *2 -1)
}