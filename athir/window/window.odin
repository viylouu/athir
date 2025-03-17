package window

import "core:c"
import "core:fmt"

import "vendor:glfw"
import inp "../input"
import gl "vendor:OpenGL"

PROGRAMNAME: cstring

GL_MAJOR_VERSION : c.int : 4
GL_MINOR_VERSION :: 6

running: b32 = true

window: glfw.WindowHandle

size_width, size_height: i32

create_window :: proc(width,height: i32, vsync: bool = true, name: cstring = "athir window") -> bool {
    PROGRAMNAME = name

    glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION) 
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)

    if !glfw.Init() {
        fmt.println("failed to init glfw!")
        return false
    }

    window = glfw.CreateWindow(width,height, PROGRAMNAME, nil,nil)

    if window == nil {
        fmt.println("failed to create window!")
        return false
    }

    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(vsync?1:0)
    glfw.SetKeyCallback(window,key_callback)
    glfw.SetFramebufferSizeCallback(window,size_callback)

    gl.load_up_to(int(GL_MAJOR_VERSION), GL_MINOR_VERSION, glfw.gl_set_proc_address)

    return true
}

key_callback :: proc "c" (window: glfw.WindowHandle, key,scancode,action,mods: i32) {
    if action == glfw.PRESS {
        inp.keystates[key] = true
    } else if action == glfw.RELEASE {
        inp.keystates[key] = false
    }
}

size_callback :: proc "c" (window: glfw.WindowHandle, width,height: i32) {
    gl.Viewport(0,0, width,height)
    size_width = width
    size_height = height
}

quit :: proc() {
    running = false
}

// converts a point in screen space to a point in ndc (opengl space)
ss_to_ndc :: proc(x,y: f32) -> (f32,f32) {
    return ((f32(x) / f32(size_width)) *2 -1), -((f32(y) / f32(size_height)) *2 -1)
}

