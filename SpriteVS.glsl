#version 330
layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 texturePosition;
out vec2 textureCoordinate;
out vec3 fragmentPosition;
out vec3 lightNormal;
uniform float rowsTile;
uniform float collumsTile;
uniform float rowPosition = 0.0;
uniform float collumsPosition = 0.0;
uniform vec3 lightPosition;
float scaleX = 1.0/rowsTile;
float scaleY = 1.0/collumsTile;
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
void main() {
   gl_Position =  projection * view* model * vec4(position ,1.0);
   textureCoordinate.x = (texturePosition.x * -1 + rowPosition)*scaleX;
   textureCoordinate.y = (texturePosition.y * -1 + collumsPosition)*scaleY;
   fragmentPosition = vec3(model * vec4(position,1.0));
   lightNormal = mat3(transpose(inverse(model))) * normal;
}
