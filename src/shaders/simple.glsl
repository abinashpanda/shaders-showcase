precision mediump float;

uniform float uAspectRatio;
uniform float uTick;
uniform vec2 uResolution;
uniform vec2 uMouse;

varying vec2 uv;

void main() {
  vec2 xy = (uv - vec2(0.5)) * vec2(uAspectRatio, 1);
  vec2 mouseXY = (uMouse / uResolution - vec2(0.5)) * vec2(uAspectRatio, -1.0);

  float d = length(xy - mouseXY);

  float color = 1.0 - smoothstep(0.1, 0.15 + pow(sin(uTick * 0.09), 2.0) * 0.1, d);
  gl_FragColor = vec4(color, 0.25, 0.25, 1.0);
}