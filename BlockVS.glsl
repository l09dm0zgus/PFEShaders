#version 330
layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 texturePosition1;
layout (location = 3) in vec2 texturePosition2;
out vec3 fragmentPosition;
out vec3 lightNormal;
out vec2 firstTextureCoordinate;
out vec2 secondTextureCoordinate;
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform float sizeX;
uniform float sizeY;
void main() {
   gl_Position =  projection * view* model * vec4(position ,1.0);
   firstTextureCoordinate = texturePosition1;
   secondTextureCoordinate = texturePosition2;
   firstTextureCoordinate.x = firstTextureCoordinate.x * sizeX;
   firstTextureCoordinate.y =firstTextureCoordinate.y *sizeY;
   secondTextureCoordinate.x = secondTextureCoordinate.x * sizeX;
   secondTextureCoordinate.y =secondTextureCoordinate.y *sizeY;
   fragmentPosition = vec3(model * vec4(position,1.0));
   lightNormal = mat3(transpose(inverse(model))) * normal;
}
