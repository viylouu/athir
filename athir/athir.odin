package athir

import w "window"
import "draw"

import "vendor:glfw"

delta: f64
lastFrameTime: f64

setup :: proc(width,height:i32, init,update,render,exit:proc(), vsync: bool = true, name: cstring = "athir window") {
    w.size_width = width
    w.size_height = height
    if !w.create_window(w.size_width,w.size_height,vsync,name) {
        return
    }

    draw.load()
    defer draw.unload()

    init()
    defer exit()

    for !glfw.WindowShouldClose(w.window) && w.running {
        glfw.PollEvents()

        delta = glfw.GetTime() - lastFrameTime
        lastFrameTime = glfw.GetTime()

        update()
        render()

        glfw.SwapBuffers(w.window)
    }
}

defer_me :: proc() {
    glfw.DestroyWindow(w.window)
    glfw.Terminate()
}

change_window_title :: proc(name: cstring) {
    w.PROGRAMNAME = name
    glfw.SetWindowTitle(w.window, name)
}