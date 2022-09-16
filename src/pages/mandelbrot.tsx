import { GLSL, Shaders } from 'gl-react'
import Canvas from 'components/canvas'
import rayMarcher from 'shaders/mandelbrot.glsl'

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
      passAspectRatioUniform
      passResolutionUniform={false}
      passMouseUniform={false}
      passTickUniform
    />
  )
}
