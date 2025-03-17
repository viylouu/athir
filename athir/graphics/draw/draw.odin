package draw

import "core:fmt"

import gl "vendor:OpenGL"
import stbt "vendor:stb/truetype"

import w "../../window"
import t "../text"

vao_rect,vbo_rect: u32
rect_verts: [12]f32

color_r,color_g,color_b,color_a: f32

prog_base: u32
prog_base_uniloc_color: i32

prog_text: u32
prog_text_uniloc_color,prog_text_uniloc_tex: i32

active_font: t.font


clear :: proc(r,g,b,a: f32) {
    gl.ClearColor(r,g,b,a)
    gl.Clear(gl.COLOR_BUFFER_BIT)
}

// must be AFTER fill
font :: proc(_font:t.font) {
    gl.UseProgram(prog_text)
    gl.Uniform4f(prog_text_uniloc_color,color_r,color_g,color_b,color_a)
    gl.Uniform1i(prog_text_uniloc_tex,0)
    active_font = _font;
}

fill :: proc(r,g,b,a:f32) {
    gl.UseProgram(prog_base);
    gl.Uniform4f(prog_base_uniloc_color,r,g,b,a)

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

    rect_verts = { 
        AAX,AAY, //0
        ABX,ABY, //1
        BBX,BBY, //2

        BBX,BBY, //2
        BAX,BAY, //3
        AAX,AAY  //0
    }

    gl.BindBuffer(gl.ARRAY_BUFFER, vbo_rect); defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
    ptr: rawptr = gl.MapBuffer(gl.ARRAY_BUFFER, gl.WRITE_ONLY)
    if ptr != nil {
        vert_ptr := cast([^]f32)ptr
        for i := 0; i < 12; i += 1 {
            vert_ptr[i] = rect_verts[i]
        }
        gl.UnmapBuffer(gl.ARRAY_BUFFER)
    } defer free(ptr, context.allocator)

    gl.BindVertexArray(vao_rect);

    gl.DrawArrays(gl.TRIANGLES,0,6)
}

text :: proc(x,y:f32, text:string) {
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D,active_font.tex)
    gl.BindVertexArray(active_font.vao)

    verts: [6*4]f32

    xpos,ypos := x,y

    for char in text {
        if (char < 32 || char >= 128) {
            continue
        }

        q: stbt.aligned_quad
        stbt.GetBakedQuad(&active_font.chardat[0],active_font.tex_width,active_font.tex_height,i32(char-32),&xpos,&ypos,&q,true)

        verts = {
            q.x0, q.y0, q.s0, q.t0,
            q.x1, q.y0, q.s1, q.t0,
            q.x1, q.y1, q.s1, q.t1,

            q.x1, q.y1, q.s1, q.t1,
            q.x0, q.y1, q.s0, q.t1,
            q.x0, q.y0, q.s0, q.t0
        }

        gl.BindBuffer(gl.ARRAY_BUFFER,active_font.vbo)
        gl.BufferSubData(gl.ARRAY_BUFFER,0,size_of(verts),&verts)
        gl.DrawArrays(gl.TRIANGLES,0,6)
    }
}