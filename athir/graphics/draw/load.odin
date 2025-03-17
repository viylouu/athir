package draw

import "core:os"
import str "core:strings"
import "core:fmt"

import w "../../window"

import gl "vendor:OpenGL"


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
    /* base program */ {
        data_vsh, ok_vsh := os.read_entire_file("assets/shaders/base.vsh", context.allocator)
        if !ok_vsh {
            fmt.println("failed to load vertex shader! (base.vsh)")
            w.quit()
            return
        } defer delete(data_vsh, context.allocator)

        c_data_vsh: cstring = str.clone_to_cstring(cast(string)data_vsh) 
        defer delete(c_data_vsh, context.allocator)

        data_fsh, ok_fsh := os.read_entire_file("assets/shaders/base.fsh", context.allocator)
        if !ok_fsh {
            fmt.println("failed to load fragment shader! (base.fsh)")
            w.quit()
            return
        } defer delete(data_fsh, context.allocator)

        c_data_fsh: cstring = str.clone_to_cstring(cast(string)data_fsh) 
        defer delete(c_data_fsh, context.allocator)

        prog_base = create_program(c_data_vsh,c_data_fsh)

        check_program_link(prog_base)

        sprog_uniloc_color := gl.GetUniformLocation(prog_base, "color")
        if sprog_uniloc_color == -1 {
            fmt.println("could not find uniform \"color\"! (base)")
            w.quit()
            return
        }
        prog_base_uniloc_color = sprog_uniloc_color
    }

    /* text program */ {
        data_vsh, ok_vsh := os.read_entire_file("assets/shaders/text.vsh", context.allocator)
        if !ok_vsh {
            fmt.println("failed to load vertex shader! (text.vsh)")
            w.quit()
            return
        } defer delete(data_vsh, context.allocator)

        c_data_vsh: cstring = str.clone_to_cstring(cast(string)data_vsh) 
        defer delete(c_data_vsh, context.allocator)

        data_fsh, ok_fsh := os.read_entire_file("assets/shaders/text.fsh", context.allocator)
        if !ok_fsh {
            fmt.println("failed to load fragment shader! (text.fsh)")
            w.quit()
            return
        } defer delete(data_fsh, context.allocator)

        c_data_fsh: cstring = str.clone_to_cstring(cast(string)data_fsh) 
        defer delete(c_data_fsh, context.allocator)

        prog_text = create_program(c_data_vsh,c_data_fsh)

        sprog_uniloc_color := gl.GetUniformLocation(prog_text, "color")
        if sprog_uniloc_color == -1 {
            fmt.println("could not find uniform \"color\"! (text)")
            w.quit()
            return
        }
        prog_text_uniloc_color = sprog_uniloc_color

        sprog_uniloc_tex := gl.GetUniformLocation(prog_text, "tex")
        if sprog_uniloc_tex == -1 {
            fmt.println("could not find uniform \"tex\"! (text)")
            w.quit()
            return
        }
        prog_text_uniloc_tex = sprog_uniloc_tex
    }
}


create_program :: proc(vsh_data,fsh_data:cstring) -> u32 {
    _vsh_data,_fsh_data := vsh_data,fsh_data
    defer delete(_vsh_data); defer delete(_fsh_data)

    vsh,fsh: u32 = gl.CreateShader(gl.VERTEX_SHADER), gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(vsh, 1, &_vsh_data, nil)
    gl.CompileShader(vsh)
    defer gl.DeleteShader(vsh)

    check_shader_compile(vsh)

    gl.ShaderSource(fsh, 1, &_fsh_data, nil)
    gl.CompileShader(fsh)
    defer gl.DeleteShader(fsh)

    check_shader_compile(fsh)

    prog := gl.CreateProgram()
    gl.AttachShader(prog,vsh)
    gl.AttachShader(prog,fsh)
    gl.LinkProgram(prog)

    return prog
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