#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec4 vertexColor;


uniform float fogScale; //= float(1.0);
uniform float fogOffset; //= float(0.0);
uniform vec4 fogColor;
uniform vec4 lightColor;
uniform vec4 shadowColor;


void main() {  
  float fogIntensity;
  float lightIntensity;
  float lightIntensityFactor;
  vec4 lightIntensityColor;
  vec4 litVertexColor;
    
  lightIntensity = max(0.0, dot(vertLightDir, vertNormal));
  lightIntensityColor = vec4(lightIntensity, lightIntensity, lightIntensity, 1.0);

  fogIntensity = gl_FragCoord.z;
  fogIntensity = fogIntensity - fogOffset;
  fogIntensity = fogIntensity / fogScale;
  
  fogIntensity = min(1.0, fogIntensity);
  fogIntensity = max(0.0, fogIntensity);
  
  //litVertexColor = lightIntensityColor*vertexColor;
  
  litVertexColor = (lightIntensity*(lightColor-shadowColor)) + shadowColor;
  
  gl_FragColor = (fogIntensity*(fogColor-litVertexColor))+litVertexColor;
  
  //gl_FragColor = (lightIntensity*(lightColor-shadowColor)) + shadowColor;
  

}