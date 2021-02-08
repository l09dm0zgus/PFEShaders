#version 330
out vec4 outColor;
in vec2 firstTextureCoordinate;
in vec2 secondTextureCoordinate;
in vec3 lightNormal;
in vec3 fragmentPosition;
uniform vec3 cameraPosition;
uniform sampler2D textures[3];
uniform int texturesCount;
struct Material
{
    vec3 specular;
    float shininess;
};

struct DirectionLight
{
    vec4 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};
struct PointLight
{
	vec4 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
	
	float constant;
    float linear;
    float quadratic;
};
struct SpotLight
{
	vec4 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
	vec3 direction;
    float cutOff;
	float outerCutOff;
	float constant;
    float linear;
    float quadratic;
};
uniform int numberOfPointLight;
uniform int numberOfSpotLight;
uniform DirectionLight directionalLight;
uniform PointLight pointLight[15];
uniform SpotLight spotLight[15];
uniform Material material;
vec3 ambient(vec3 lightAmbient)
{
    vec3 ambientColor = vec3(texture(textures[0],firstTextureCoordinate))* lightAmbient;
	return ambientColor;
}
vec3 diffuse(vec4 lightPosition,vec3 lightDiffuse,inout vec3 lightDirection,inout vec3 normal)
{
	normal = normalize(lightNormal);
	if(lightPosition.w == 0.0)
	{
		lightDirection = normalize(vec3(-lightPosition.x,-lightPosition.y,-lightPosition.z));
	}
	else if(lightPosition.w == 1.0)
	{
		lightDirection = normalize(vec3(lightPosition.x,lightPosition.y,lightPosition.z) - fragmentPosition);
	}
	float difference = max(dot(normal,lightDirection),0.0);
	vec3 diffuseColor = (difference*vec3(texture(textures[0],firstTextureCoordinate)))* lightDiffuse;
	return diffuseColor;
}
vec3 specular(vec3 lightSpecular,vec3 lightDirection ,vec3 normal)
{
	vec3 specularColor;
	vec3 viewDirection;
	vec3 reflectDirection;
	float spec;
	switch(texturesCount)
	{
		case 1:
			viewDirection = normalize(cameraPosition - fragmentPosition);
			reflectDirection = reflect(-lightDirection, normal);  
			spec = pow(max(dot(viewDirection, reflectDirection), 0.0), material.shininess);
			specularColor = (material.specular * spec )* lightSpecular;
		break;
		case 2:
			viewDirection = normalize(cameraPosition - fragmentPosition);
			reflectDirection = reflect(-lightDirection, normal);  
			spec = pow(max(dot(viewDirection, reflectDirection), 0.0), material.shininess);
			specularColor = (spec *vec3(texture(textures[1],firstTextureCoordinate)))* lightSpecular;
		break;
	}
	return specularColor;
}
vec3 emission()
{
	if(texturesCount == 3)
	{
		return vec3(texture(textures[2],secondTextureCoordinate));
	}
	return vec3(0,0,0);
}
vec3 calculateDirectLight(DirectionLight directionalLight)
{
	vec3 normal = vec3(0);
	vec3 lightDirection = vec3(0);
    vec3 ambientColor = ambient(directionalLight.ambient);
	vec3 diffuseColor = diffuse(directionalLight.position,directionalLight.diffuse,lightDirection,normal);
	vec3 specularColor = specular(directionalLight.specular,lightDirection,normal);
	vec3 result = (ambientColor + diffuseColor+specularColor + emission());
	return result;
}
vec3 calculatePointLight(PointLight pointLight)
{
	vec3 normal = vec3(0);
	vec3 lightDirection = vec3(0) ;
    vec3 ambientColor = ambient(pointLight.ambient);
	vec3 diffuseColor = diffuse(pointLight.position,pointLight.diffuse,lightDirection,normal);
	vec3 specularColor = specular(pointLight.specular,lightDirection,normal);
	float dist = length(pointLight.position.xyz-fragmentPosition);
	float attenuation = 1.0/(pointLight.constant+pointLight.linear * dist + pointLight.quadratic*(dist * dist));
	ambientColor *= attenuation;
	diffuseColor *= attenuation;
	specularColor *= attenuation;
	vec3 result = (ambientColor + diffuseColor+specularColor + emission());
	return result;
}
vec3 calculateSpotLight(SpotLight spotLight)
{
	float theta = dot(normalize(spotLight.position.xyz-fragmentPosition),normalize(-spotLight.direction));
	float epsilion = spotLight.cutOff - spotLight.outerCutOff;
	float intensity = clamp((theta-spotLight.outerCutOff)/epsilion,0.0,1.0);
	vec3 normal = vec3(0);
	vec3 lightDirection = vec3(0);
    float dist = length(spotLight.position.xyz - fragmentPosition);
    float attenuation = 1.0 / (spotLight.constant + spotLight.linear * dist + spotLight.quadratic * (dist * dist));  
	
	vec3 ambientColor = ambient(spotLight.ambient);
	vec3 diffuseColor = diffuse(spotLight.position,spotLight.diffuse,lightDirection,normal);
	vec3 specularColor = specular(spotLight.specular,lightDirection,normal);
	ambientColor *= attenuation * intensity;
	diffuseColor *=  attenuation * intensity;
	specularColor *= attenuation * intensity;
	vec3 result = (ambientColor + diffuseColor+specularColor + emission());
	return result;
}
void main() {
    vec3 result = calculateDirectLight(directionalLight);
	for(int i=0;i<numberOfPointLight;i++)
	{
		result += calculatePointLight(pointLight[i]);
	}
	for(int i=0;i<numberOfSpotLight;i++)
	{
		result += calculateSpotLight(spotLight[i]);
	}
    outColor =  vec4(result,1.0);
}
