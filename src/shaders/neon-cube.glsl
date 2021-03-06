/**
DO NOT EDIT THIS FILE!

It should be only used as a template for creating new ray-marcher.
*/

#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .001
#define ZOOM 0.5

precision mediump float;

varying vec2 uv;

uniform float uTick;
uniform float uAspectRatio;
uniform vec2 uMouse;
uniform vec2 uResolution;

// helper utitlity functions

mat2 rotate(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s, s, c);
}

// smooth min functions

float smin(float a, float b, float k) {
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

// sdf

float sdBox(vec3 point, vec3 size) {
  point = abs(point) - size;
  return length(max(point, 0.)) + min(max(point.x, max(point.y, point.z)), 0.);
}

float sdBoxFrame(vec3 point, vec3 b, float e) {
  point = abs(point) - b;
  vec3 q = abs(point + e) - e;
  return min(min(length(max(vec3(point.x, q.y, q.z), 0.0)) + min(max(point.x, max(q.y, q.z)), 0.0), length(max(vec3(q.x, point.y, q.z), 0.0)) + min(max(q.x, max(point.y, q.z)), 0.0)), length(max(vec3(q.x, q.y, point.z), 0.0)) + min(max(q.x, max(q.y, point.z)), 0.0));
}

// ray march functions

float getDistance(vec3 point) {
  float d = sdBoxFrame(point, vec3(1.0), 0.025);
  return d;
}

float rayMarch(vec3 rayOrigin, vec3 rayDirection) {
  float dO = 0.;

  for(int i = 0; i < MAX_STEPS; i++) {
    vec3 point = rayOrigin + rayDirection * dO;
    float dS = getDistance(point);
    dO += dS;
    if(dO > MAX_DIST || abs(dS) < SURF_DIST)
      break;
  }

  return dO;
}

vec3 getNormal(vec3 point) {
  float d = getDistance(point);
  vec2 epsilon = vec2(.001, 0);
  vec3 n = d - vec3(getDistance(point - epsilon.xyy), getDistance(point - epsilon.yxy), getDistance(point - epsilon.yyx));
  return normalize(n);
}

vec3 getRayDirection(vec2 uv, vec3 cameraPosition, vec3 lookatPoint, float zoom) {
  vec3 forward = normalize(lookatPoint - cameraPosition);
  vec3 right = normalize(cross(vec3(0, 1, 0), forward));
  vec3 up = cross(forward, right);
  vec3 center = forward * zoom;
  vec3 pointOnScreen = center + uv.x * right + uv.y * up;
  return normalize(pointOnScreen);
}

void main() {
  vec2 pos = (uv - vec2(0.5)) * vec2(uAspectRatio, 1);
  vec2 mouse = uMouse / uResolution;

  vec3 rayOrigin = vec3(0, 3, -3);
  rayOrigin.yz *= rotate(-mouse.y * 3.14 + 1.);
  rayOrigin.xz *= rotate(-mouse.x * 6.2831);

  vec3 rayDirection = getRayDirection(pos, rayOrigin, vec3(0, 0., 0), ZOOM);
  vec3 color = vec3(0);

  float d = rayMarch(rayOrigin, rayDirection);
  if(d < MAX_DIST) {
    vec3 p = rayOrigin + rayDirection * d;
    vec3 n = getNormal(p);
    // vec3 r = reflect(rayDirection, n);

    float diffuseLighting = dot(n, normalize(vec3(1, 2, 3))) * .5 + .5;
    color = vec3(diffuseLighting);
  }

  // gamma correction
  color = pow(color, vec3(.4545));

  gl_FragColor = vec4(color, 1.0);
}