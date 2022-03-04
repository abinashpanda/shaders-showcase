/**
DO NOT EDIT THIS FILE!

It should be only used as a template for creating new ray-marcher.
*/

#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .001
#define T uTick * 0.004

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

float sdGyroid(vec3 point, float scale, float thickness, float bias) {
  point *= scale;
  return abs((dot(sin(point), cos(point.zxy)) - bias) / scale) - thickness;
}

// ray march functions

vec3 transform(vec3 point) {
  point.z -= T;
  point.y -= 0.4;
  point.xy *= rotate(point.z * 0.001);
  return point;
}

float getDistance(vec3 point) {
  // float box = sdBox(point, vec3(1));
  point = transform(point);

  float g1 = sdGyroid(point, 5.43, 0.02, 1.3);
  float g2 = sdGyroid(point, 9.34, 0.03, 0.3);
  float g3 = sdGyroid(point, 15.56, 0.03, 0.2);
  float g4 = sdGyroid(point, 31.56, 0.03, 0.2);
  float g5 = sdGyroid(point, 60.56, 0.03, 0.2);
  float g6 = sdGyroid(point, 123.56, 0.03, 0.2);

  g1 -= g2 * 0.4;
  g1 -= g3 * 0.3;
  g1 += g4 * 0.2;
  g1 += g5 * 0.2;
  g1 += g6 * 0.05;

  // float d = max(box, g1 * 0.8);
  float d = g1 * 0.8;
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
  // the closer you sample the sharper the line becomes, so we can reduce it 0.01
  vec2 epsilon = vec2(.01, 0);
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

vec3 background(vec3 rayDirection) {
  vec3 color = vec3(0.);
  float y = rayDirection.y * 0.5 + 0.5;
  color += (1.0 - y) * vec3(1, 0.4, 0.1) * 2.0;

  // get the xz angle
  float angle = atan(rayDirection.x, rayDirection.z);
  float flame = sin(angle * 10. + T) * sin(angle * 7.0 - T);
  // do not merge the lines at top
  flame *= smoothstep(0.8, 0.5, y);

  color += flame;
  color = max(color, 0.0);
  color += smoothstep(0.5, 0., y);

  return color;
}

void main() {
  vec2 pos = (uv - vec2(0.5)) * vec2(uAspectRatio, 1);
  pos += sin(pos * 20.0 + T) * 0.01;
  vec2 mouse = uMouse / uResolution;

  vec3 rayOrigin = vec3(0, 0, 0.1);
  rayOrigin.yz *= rotate(-mouse.y * 3.14 + 1.);
  rayOrigin.xz *= rotate(-mouse.x * 6.2831);

  vec3 rayDirection = getRayDirection(pos, rayOrigin, vec3(0, 0., 0), 0.5);
  vec3 color = vec3(0);

  float d = rayMarch(rayOrigin, rayDirection);
  if(d < MAX_DIST) {
    vec3 p = rayOrigin + rayDirection * d;
    float height = p.y;

    vec3 n = getNormal(p);

    p = transform(p);

    float diffuseLighting = n.y * .5 + .5;
    color = vec3(diffuseLighting * diffuseLighting);
    // color = n * 0.5 + 0.5;

    // ambient occlusion
    // g2 is the second gyroid used
    // as its value can be in the range of -1 to 1 and it would be zero on the surface, we can use it to reduce the color which is a cheaper way of
    // ambient occlusion
    float g2 = sdGyroid(p, 9.34, 0.03, 0.3);
    // the value g2 in the point of intersection doesn't go below 0.1, so we increase the boundary then it would darken the whole image
    color *= smoothstep(-0.08, 0.08, g2);

    // add cracks
    float crackWidth = -0.02 + smoothstep(0.0, -0.5, n.y) * 0.02;
    float cracks = smoothstep(crackWidth, -0.03, g2);
    float g3 = sdGyroid(p + T, 4.56, 0.03, 0.);
    float g4 = sdGyroid(p - T * 2.0, 5.34, 0.03, 0.);
    cracks *= g3 * g4 * 20.0 + smoothstep(0.2, 0.0, n.y) * 0.2;

    color += cracks * vec3(1.0, 0.33, 0.04) * 4.0;

    float g5 = sdGyroid(p - vec3(0, T * 2.0, 0), 5.34, 0.03, 0.);
    color += g5 * vec3(1.0, 0.4, 0.1) * 0.5;

    color += smoothstep(0.0, -0.2, height) * vec3(1.0, 0.4, 0.1) * 0.5;
  }

  color = mix(color, background(rayDirection), smoothstep(0., 7., d));

  color *= smoothstep(1.7, 0., dot(pos, pos));
  // gamma correction
  color = pow(color, vec3(.4545));

  gl_FragColor = vec4(color, 1.0);
}