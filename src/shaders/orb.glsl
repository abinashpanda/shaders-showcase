/**
Inspired from https://www.youtube.com/watch?v=b0AayhCO7s8

All thanks to "Art of Code" channel
*/

#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .001
#define T uTick * 0.01
#define TAU 6.28315

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

float sdSphere(vec3 point, float radius) {
  return length(point) - radius;
}

float sdGyroid(vec3 point) {
  point.yz *= rotate(T);
  point *= 10.0;
  // multiply with 0.7 as this is not a perfect distance
  // abs makes the inside as outside, so that the gryoid is a shell
  // and we subtract 0.03 to give some thickness
  return abs(0.7 * dot(sin(point), cos(point.zxy)) / 10.0) - 0.03;
}

// ray march functions

float getDistance(vec3 point) {
  // make the ball a shell by taking abs and subtracting 0.03
  float ball = abs(sdSphere(point, 1.0)) - 0.03;
  float gyroid = sdGyroid(point);
  ball = smin(ball, gyroid, -0.03);

  float ground = point.y + 1.0;
  point.z -= T;
  point *= 5.0;
  point.y += sin(point.z) * 0.5;
  float y = abs(dot(sin(point), cos(point.yzx))) * 0.1;
  ground += y;
  return min(ball, ground * 0.9);
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

float hash21(vec2 point) {
  point = fract(point * vec2(123.9898, 278.233));
  point += dot(point, point + 23.4);
  return fract(point.x * point.y);
}

float glitter(vec2 uv, float phase) {
  uv *= 10.0;
  vec2 id = floor(uv);
  float noise = hash21(id);

  uv = fract(uv) - 0.5;
  float d = length(uv);
  float m = smoothstep(noise * 0.3, 0.0, d);
  // convert one random to another multiply with 10 and take fract
  m *= pow(sin(phase + fract(noise * 10.0) * TAU) * 0.5 + 0.5, 100.0);
  return m;
}

void main() {
  vec2 pos = (uv - vec2(0.5)) * vec2(uAspectRatio, 1);
  vec2 mouse = uMouse / uResolution;

  vec3 rayOrigin = vec3(0, 3, -3);
  rayOrigin.yz *= rotate(-mouse.y * 3.14 + 1.);
  rayOrigin.xz *= rotate(-mouse.x * 6.2831);
  rayOrigin.y = max(-0.9, rayOrigin.y);

  vec3 rayDirection = getRayDirection(pos, rayOrigin, vec3(0, 0., 0), 1.3);
  vec3 color = vec3(0);

  float d = rayMarch(rayOrigin, rayDirection);
  if(d < MAX_DIST) {
    vec3 p = rayOrigin + rayDirection * d;
    vec3 n = getNormal(p);

    vec3 lightDirection = -normalize(p);
    float diffuseLighting = dot(n, lightDirection) * .5 + .5;
    color = vec3(diffuseLighting);

    float distFromOrigin = length(p);
    // including the thickness of the sphere
    if(distFromOrigin > 1.03) {
      float s = sdGyroid(-lightDirection);
      // weight of the shadow
      // if the point is nearer to the shadow should be thin (meaning smaller w)
      float w = distFromOrigin * 0.01;
      // if the point is on gyroid, the value would be zero, else it would be one
      float shadow = smoothstep(-w, w, s);
      // so if we multiply the shadow with the diffuse lighting, we get the final color
      color *= shadow * 0.9 + 0.1;

      // add some glitter
      p.z += T * 0.5;
      // multipling with shadow makes sure that the sparkles are not visible inside it
      color += glitter(p.xz, dot(rayOrigin, vec3(2.0))) * 3.0 * shadow;

      // reduce the lighting with distance
      color /= distFromOrigin * distFromOrigin;
    }
  }

  float centerDistance = dot(pos, pos);
  float light = 0.001 / centerDistance;
  // @TODO: make meaning of it
  color += light * smoothstep(0.0, 0.5, d - 4.0);

  // direction of light is from rayOrigin to center of ball with is rayOrigin itself
  float s = sdGyroid(normalize(rayOrigin));
  // @TODO: make meaning of it
  color += light * smoothstep(0., 0.2, s);

  // gamma correction
  color = pow(color, vec3(.4545));

  // color *= 0.0;
  // color += glitter(pos);

  gl_FragColor = vec4(color, 1.0);
}