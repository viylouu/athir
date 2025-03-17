package text

import "core:os"
import "core:fmt"
import str "core:strings"

import w "../../window"

import gl "vendor:OpenGL"
import stbt "vendor:stb/truetype"

font :: struct {
    tex: u32,
    chardat: [^]stbt.bakedchar,
    tex_width,tex_height: i32,
    vao,vbo: u32
}

load_font :: proc(path: cstring, font_size:i32) -> font {
    data, ok := os.read_entire_file("assets/shaders/base.vsh", context.allocator)
    if !ok {
        fmt.println("failed to load vertex shader!")
        w.quit()
        return font{}
    } defer delete(data, context.allocator)

    dataptr: [^]u8 = raw_data(data)
    //defer free(dataptr)

    tex_width,tex_height: i32 = 512,512
    bitmap: [^]u8 = make([^]u8, tex_width * tex_height)
    if bitmap == nil {
        fmt.println("bitmap alloc failed!")
        w.quit()
        return font{}
    }
    //defer free(bitmap)

    chardata: [^]stbt.bakedchar = make([^]stbt.bakedchar,96)
    if chardata == nil {
        fmt.println("chardata alloc failed!")
        w.quit()
        return font{}
    }
    //defer free(chardata)
    stbt.BakeFontBitmap(dataptr, 0, 32, bitmap, 512,512, 32, 96, chardata)

    tex: u32
    gl.GenTextures(1, &tex)
    gl.BindTexture(gl.TEXTURE_2D, tex)
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RED, 512,512, 0, gl.RED, gl.UNSIGNED_BYTE, bitmap)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

    vao,vbo: u32
    gl.GenVertexArrays(1,&vao)
    gl.GenBuffers(1,&vbo)

    gl.BindVertexArray(vao)
    gl.BindBuffer(gl.ARRAY_BUFFER,vbo)
    gl.BufferData(gl.ARRAY_BUFFER, 6*4*size_of(f32), nil, gl.DYNAMIC_DRAW)

    gl.EnableVertexAttribArray(0)
    gl.VertexAttribPointer(0,2, gl.FLOAT, false, 4*size_of(f32), 0)

    gl.EnableVertexAttribArray(1)
    gl.VertexAttribPointer(1,2, gl.FLOAT, false, 4*size_of(f32), 2*size_of(f32))

    return font{tex,chardata,tex_width,tex_height,vao,vbo}
}