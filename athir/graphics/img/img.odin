package img

import "core:fmt"

import stbi "vendor:stb/image"
import gl "vendor:OpenGL"

load_tex :: proc(path: cstring) -> u32 {
    tex_id: u32
    gl.GenTextures(1, &tex_id)
    gl.BindTexture(gl.TEXTURE_2D, tex_id)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

    width,height,channels: i32
    data := stbi.load(path, &width, &height, &channels, 0)
    if data == nil {
        fmt.println("failed to load texture from path ", path)
        return 0
    }

    format: i32 = (channels==4)? gl.RGBA : gl.RGB

    gl.TexImage2D(gl.TEXTURE_2D, 0, format, width, height, 0, u32(format), gl.UNSIGNED_BYTE, data)
    gl.GenerateMipmap(gl.TEXTURE_2D)

    stbi.image_free(data)

    return tex_id
}