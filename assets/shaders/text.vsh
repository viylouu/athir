#version 330 core

layout(location = 0) in vec2 aposition;
layout(location = 1) in vec2 atexcoord;

out vec2 texcoord;

void main() {
    texcoord = atexcoord;
    gl_Position = vec4(aposition,0,1);
}