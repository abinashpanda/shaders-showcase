import { GLSL, Shaders } from 'gl-react'
import Canvas from 'components/canvas'
import rayMarcher from 'shaders/fractal.glsl'

const shader = Shaders.create({
  rayMarcher: {
    frag: GLSL`${rayMarcher}`,
  },
})

export default function RayMarcher() {
  return (
    <Canvas
      className="h-screen overflow-hidden"
      shader={shader.rayMarcher}
      uniforms={{ uMatcap1: 'matcap1.png', uMatcap2: 'matcap2.png' }}
    />
  )
}
