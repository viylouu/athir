package draw

import "core:fmt"
import "core:os"
import str "core:strings"

import gl "vendor:OpenGL"

import w "../../window"

vao_rect,vbo_rect: u32

color_r,color_g,color_b,color_a: f32

prog_base: u32
prog_base_uniloc_color: i32


unload :: proc() {
    
}


load :: proc() {
    load_buffers()
    load_shaders()
}

load_buffers :: proc() {
    /* rect */ {
        gl.GenVertexArrays(1,&vao_rect)
        gl.GenBuffers(1,&vbo_rect)

        gl.BindVertexArray(vao_rect)
        gl.BindBuffer(gl.ARRAY_BUFFER, vbo_rect)

        gl.BufferData(gl.ARRAY_BUFFER, 12*size_of(f32), nil, gl.DYNAMIC_DRAW)

        gl.VertexAttribPointer(0,2, gl.FLOAT, gl.FALSE, 2*size_of(f32), 0)
        gl.EnableVertexAttribArray(0)

        gl.BindVertexArray(0)
    }
}

load_shaders :: proc() {
    data_vsh, ok_vsh := os.read_entire_file("assets/shaders/base.vsh", context.allocator)
    if !ok_vsh {
        fmt.println("failed to load vertex shader!")
        return
    } defer delete(data_vsh, context.allocator)

    c_data_vsh := str.clone_to_cstring(cast(string)data_vsh) 
    defer delete(c_data_vsh, context.allocator)

    data_fsh, ok_fsh := os.read_entire_file("assets/shaders/base.fsh", context.allocator)
    if !ok_fsh {
        fmt.println("failed to load fragment shader!")
        return
    } defer delete(data_fsh, context.allocator)

    c_data_fsh := str.clone_to_cstring(cast(string)data_fsh) 
    defer delete(c_data_fsh, context.allocator)


    vsh,fsh := gl.CreateShader(gl.VERTEX_SHADER), gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(vsh, 1, &c_data_vsh, nil)
    gl.CompileShader(vsh)
    defer gl.DeleteShader(vsh)

    check_shader_compile(vsh)

    gl.ShaderSource(fsh, 1, &c_data_fsh, nil)
    gl.CompileShader(fsh)
    defer gl.DeleteShader(fsh)

    check_shader_compile(fsh)

    prog_base = gl.CreateProgram()
    gl.AttachShader(prog_base,vsh)
    gl.AttachShader(prog_base,fsh)
    gl.LinkProgram(prog_base)

    check_program_link(prog_base)

    sprog_uniloc_color := gl.GetUniformLocation(prog_base, "color")
    if sprog_uniloc_color == -1 {
        fmt.println("could not find uniform \"color\"!")
        return
    }
}


// drawing functions

clear :: proc(r,g,b,a: f32) {
    gl.ClearColor(r,g,b,a)
    gl.Clear(gl.COLOR_BUFFER_BIT)
}

fill :: proc(r,g,b,a:f32) {
    color_r = r
    color_g = g
    color_b = b
    color_a = a
}

rect :: proc(x,y,width,height: f32) {
    AAX, AAY := w.ss_to_ndc(x,y)
    ABX, ABY := w.ss_to_ndc(x,y+height)
    BAX, BAY := w.ss_to_ndc(x+width,y)
    BBX, BBY := w.ss_to_ndc(x+width,y+height)

    vertices: [12]f32 = { 
        AAX,AAY, //0
        ABX,ABY, //1
        BBX,BBY, //2

        BBX,BBY, //2
        BAX,BAY, //3
        AAX,AAY  //0
    }

    gl.BindBuffer(gl.ARRAY_BUFFER, vbo_rect); defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
    ptr := gl.MapBuffer(gl.ARRAY_BUFFER, gl.WRITE_ONLY)
    if ptr != nil {
        vert_ptr := cast([^]f32)ptr
        for i := 0; i < 12; i += 1 {
            vert_ptr[i] = vertices[i]
        }
        gl.UnmapBuffer(gl.ARRAY_BUFFER)
    } defer free(ptr, context.allocator)

    gl.UseProgram(prog_base); defer gl.UseProgram(0)
    gl.BindVertexArray(vao_rect); defer gl.BindVertexArray(0)

    gl.Uniform4f(prog_base_uniloc_color,color_r,color_g,color_b,color_a)

    gl.DrawArrays(gl.TRIANGLES,0,6)
}

check_shader_compile :: proc(shader: u32) {
    success: i32
    gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success)
    if success == 0 {
        log: [512]u8
        gl.GetShaderInfoLog(shader, 512, nil, &log[0])
        fmt.println("Shader compilation failed: ", log)
    }
}

check_program_link :: proc(prog: u32) {
    success: i32
    gl.GetProgramiv(prog, gl.LINK_STATUS, &success)
    if success == 0 {
        log: [512]u8
        gl.GetProgramInfoLog(prog, 512, nil, &log[0])
        fmt.println("Program linking failed: ", log)
    }
}