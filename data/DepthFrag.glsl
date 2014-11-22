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


void main() {  
  float fogIntensity;
  float lightIntensity;
  vec4 lightColor;
  vec4 litVertexColor;
    
  lightIntensity = max(0.0, dot(vertLightDir, vertNormal));
  lightColor = vec4(lightIntensity, lightIntensity, lightIntensity, 1.0);

  fogIntensity = gl_FragCoord.z;
  fogIntensity = fogIntensity - fogOffset;
  fogIntensity = fogIntensity / fogScale;
  
  fogIntensity = min(1.0, fogIntensity);
  fogIntensity = max(0.0, fogIntensity);
  
  litVertexColor = lightColor*vertexColor;
  
  //gl_FragColor = (fogIntensity*(fogColor-litVertexColor))+litVertexColor;
  
  gl_FragColor = vec4(vec3(fogIntensity), 1);
  

}