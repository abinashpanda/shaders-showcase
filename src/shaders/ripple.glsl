#define PI 3.14159264

precision mediump float;

varying vec2 uv;

uniform float uTick;
uniform sampler2D uPattern;
uniform float uAspectRatio;
uniform float uPatternAspectRatio;
uniform vec2 uCenter;
uniform vec2 uResolution;

mat2 rotate(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s, s, c);
}

#define NUM_OCTAVES 5

float rand(vec2 n) {
  return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 ip = floor(p);
  vec2 u = fract(p);
  u = u * u * (3.0 - 2.0 * u);

  float res = mix(mix(rand(ip), rand(ip + vec2(1.0, 0.0)), u.x), mix(rand(ip + vec2(0.0, 1.0)), rand(ip + vec2(1.0, 1.0)), u.x), u.y);
  return res * res;
}

float fbm(vec2 x) {
  float v = 0.0;
  float a = 0.5;
  vec2 shift = vec2(100);
  // Rotate to reduce axial bias
  mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
  for(int i = 0; i < NUM_OCTAVES; ++i) {
    v += a * noise(x);
    x = rot * x * 2.0 + shift;
    a *= 0.5;
  }
  return v;
}

float exponentialIn(float t) {
  return t == 0.0 ? t : pow(2.0, 10.0 * (t - 1.0));
}

vec2 aspectRatio(vec2 uv, float canvasAspectRatio, float textureAspectRatio) {
  vec2 coords = uv;
  coords = mix(vec2(0.1), vec2(0.9), coords);

  float diff = textureAspectRatio / canvasAspectRatio;

  if(diff > 1.0) {
    // the texture is more landscapeish than the canvas
    // then make the coords.y to go from 0...1 and limit the coords.x
    coords.x *= 1.0 / diff;
    coords.x += (1.0 - 1.0 / diff) / 2.0;
  } else {
    // the texture is more potraitish than the canvas
    // then make the coords.x go from 0...1 and limit the coords.y
    coords.y *= diff;
    coords.y += (1.0 - diff) / 2.0;
  }

  return coords;
}

void main() {
  vec2 coords = aspectRatio(uv, uAspectRatio, uPatternAspectRatio);

  float time = uTick * 0.005;
  float t = sin(time) * sin(time);
  t = exponentialIn(t);

  float scale = mix(1.0, 3.0, t);
  vec2 pageCenter = uCenter / uResolution;
  pageCenter.y = 1.0 - pageCenter.y;
  // vec2 cPos = (mix(vec2(0.0), vec2(scale), uv) - scale / 2.0 * pageCenter) * vec2(uAspectRatio, 1.0);
  vec2 cPos = (uv - pageCenter) * vec2(uAspectRatio, 1.0);
  cPos *= scale;
  float cLength = length(cPos);

  float r = cLength;
  r += time * 0.5;
  r = fract(r);

  float segments = 10.0;
  float angle = atan(cPos.y, cPos.x);
  angle /= PI * 2.0;
  angle *= segments;
  angle = fract(angle);
  angle += mix(0.25 * PI, PI, t);
  angle /= segments;
  angle *= PI * 2.0;

  vec2 point = vec2(r * cos(angle), r * sin(angle));
  point *= rotate(mix(5.0, 5.5, 1.0 - t));

  point += rand(point) * 0.01;

  float f = smoothstep(0.0, 1.0, coords.x);

  vec2 disp = cPos / cLength * cos(cLength * 12.0 - 4.0 * time) * 0.03;
  disp += (cPos - vec2(0.05, 0.05)) / cLength * cos(cLength * 12.0 - 9.0 * time) * 0.02;

  float colorDistort = rand(cPos);
  float distortStrength = 0.01 * smoothstep(0.0, 0.8, t) + 0.01 * smoothstep(0.5, 0.6, cLength);
  distortStrength /= 1.5;

  vec4 greenChannel = texture2D(uPattern, point + disp + colorDistort * distortStrength);
  greenChannel.r = 0.0;
  greenChannel.b = 0.0;

  vec4 blueChannel = texture2D(uPattern, point + disp + vec2(colorDistort * distortStrength));
  blueChannel.r = 0.0;
  blueChannel.g = 0.0;

  vec4 redChannel = texture2D(uPattern, point + disp - vec2(0.0, colorDistort * distortStrength));
  redChannel.b = 0.0;
  redChannel.g = 0.0;

  vec4 color = greenChannel + blueChannel + redChannel;

  gl_FragColor = color;
  // gl_FragColor = smoothstep(0.0, 0.1, cLength) * vec4(1.0, 0.0, 0.0, 1.0);
}
