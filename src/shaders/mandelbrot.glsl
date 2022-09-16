precision highp float;

#define MAX_ITERATIONS 100.0
#define TIME uTick * 0.02
#define AA 3

varying vec2 uv;

uniform float uAspectRatio;
uniform float uTick;

mat2 rotate(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s, s, c);
}

// This shader computes the distance to the Mandelbrot Set for everypixel, and colorizes
// it accoringly.
// 
// Z -> Z²+c, Z0 = 0. 
// therefore Z' -> 2·Z·Z' + 1
//
// The Hubbard-Douady potential G(c) is G(c) = log Z/2^n
// G'(c) = Z'/Z/2^n
//
// So the distance is |G(c)|/|G'(c)| = |Z|·log|Z|/|Z'|
//
// More info here: https://iquilezles.org/articles/distancefractals

vec4 distanceToMandelbrot(in vec2 c) {
  //   #if 1
  // {
  //   float c2 = dot(c, c);
  //       // skip computation inside M1 - https://iquilezles.org/articles/mset1bulb
  //   if(256.0 * c2 * c2 - 96.0 * c2 + 32.0 * c.x - 3.0 < 0.0)
  //     return 0.0;
  //       // skip computation inside M2 - https://iquilezles.org/articles/mset2bulb
  //   if(16.0 * (c2 + 2.0 * c.x + 1.0) - 1.0 < 0.0)
  //     return 0.0;
  // }
  //   #endif

  // iterate
  float di = 1.0;
  vec2 z = vec2(0.0);
  float m2 = 0.0;
  vec2 dz = vec2(0.0);
  float trap1 = 0.0;
  float trap2 = 1e20;
  float co2 = 0.0;
  vec2 t2c = vec2(-0.5, 2.0);
  t2c += 0.5 * vec2(cos(0.13 * (TIME - 10.0)), sin(0.13 * (TIME - 10.0)));
  for(int i = 0; i < 300; i++) {
    if(m2 > 1024.0) {
      di = 0.0;
      break;
    }

		// Z' -> 2·Z·Z' + 1
    dz = 2.0 * vec2(z.x * dz.x - z.y * dz.y, z.x * dz.y + z.y * dz.x) + vec2(1.0, 0.0);

    // Z -> Z² + c			
    z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;

    // trap 1
    float d1 = abs(dot(z - vec2(0.0, 1.0), vec2(0.707)));
    float ff = 1.0 - smoothstep(0.6, 1.4, d1);
    co2 += ff;
    trap1 += ff * d1;

		//trap2
    trap2 = min(trap2, dot(z - t2c, z - t2c));

    m2 = dot(z, z);
  }

  // distance	
	// d(c) = |Z|·log|Z|/|Z'|
  float d = 0.5 * sqrt(dot(z, z) / dot(dz, dz)) * log(dot(z, z));
  if(di > 0.5)
    d = 0.0;

  return vec4(d, trap1, trap2, co2);
}

void main() {
  vec2 pos = 2.0 * uv - vec2(1.0);
  pos.x *= uAspectRatio;
  float tz = 0.5 - 0.5 * cos(0.225 * TIME);
  float zoo = pow(0.5, 13.0 * tz);
  vec2 c = vec2(-0.05, .6805) + pos * zoo;
  // c *= rotate(TIME * 0.01);
  vec4 m = distanceToMandelbrot(c);
  float d = m.x;
  float trap1 = m.y;
  float trap2 = m.z;
  float co2 = m.w;
  d = clamp(pow(4.0 * d / zoo, 0.2), 0.0, 1.0);
  float c1 = pow(clamp(2.00 * d / zoo, 0.0, 1.0), 0.5);
  float c2 = pow(clamp(1.5 * trap1 / co2, 0.0, 1.0), 2.0);
  float c3 = pow(clamp(0.4 * trap2, 0.0, 1.0), 0.25);
  vec3 col = vec3(0.0);
  vec3 col1 = 0.5 + 0.5 * sin(3.0 + 4.0 * c2 + vec3(0.2706, 0.3373, 0.1608));
  vec3 col2 = 0.5 + 0.5 * sin(4.1 + 2.0 * c3 + vec3(0.9373, 0.5294, 0.5294));
  col += 2.0 * sqrt(c1 * col1 * col2);
  // col /= float(AA * AA);
  gl_FragColor = vec4(col, 1.0);
}