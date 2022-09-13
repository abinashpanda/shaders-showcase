import { GLSL, Shaders } from 'gl-react'
import Canvas from 'components/canvas'
import rayMarcher from 'shaders/study-table.glsl'

const shader = Shaders.create({
  rayMarcher: {
    frag: GLSL`${rayMarcher}`,
  },
})

export default function RayMarcher() {
  return <Canvas className="h-screen overflow-hidden" shader={shader.rayMarcher} passTickUniform={false} />
}
