#version 330 core

uniform vec4 color;

in vec2 texcoord;

out vec4 fin;

uniform sampler2D tex;

void main() {
    fin = color * texture(tex,texcoord);
}