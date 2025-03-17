package input

import "vendor:glfw"

keystates: [350]bool

key_callback :: proc "c" (window: glfw.WindowHandle, key,scancode,action,mods: i32) {
    if action == glfw.PRESS {
        keystates[key] = true
    } else if action == glfw.RELEASE {
        keystates[key] = false
    }
}


is_key_down :: proc(key: int) -> bool {
    return keystates[key]
}