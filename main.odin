package main

import "core:fmt"
import str "core:strings"

import "vendor:glfw"

import a "athir"
import "athir/graphics/draw"
import inp "athir/input"
import t "athir/graphics/text"
import w "athir/window"

player_x,player_y: f32
dfont: t.font

main :: proc() {
    a.setup(512,512,init,update,render,exit,false)
}

init :: proc() {
    dfont = t.load_font("assets/fonts/Chivo-Light.ttf",16)
}

update :: proc() {
    if inp.is_key_down(glfw.KEY_A) {
        player_x -= 256 * cast(f32)a.delta
    } if inp.is_key_down(glfw.KEY_D) {
        player_x += 256 * cast(f32)a.delta
    } if inp.is_key_down(glfw.KEY_W) {
        player_y -= 256 * cast(f32)a.delta
    } if inp.is_key_down(glfw.KEY_S) {
        player_y += 256 * cast(f32)a.delta
    }
}

render :: proc() {
    draw.clear(0,0,1,1)

    draw.fill(1,0,0,1)
    draw.rect(player_x,player_y,128,128)

    draw.fill(1,1,1,1)
    draw.rect(256,0,128,128)

    draw.fill(0,1,1,1)
    draw.rect(0,256,128,128)

    draw.fill(1,1,0,1)
    draw.rect(256,256,128,128)

    draw.fill(1,1,1,1)
    draw.font(dfont)
    draw.text(0,0, "hello!")
}

exit :: proc() {
    
}