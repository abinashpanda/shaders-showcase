import { GLSL, Shaders } from 'gl-react'
import Canvas from 'components/canvas'
import fire from 'shaders/fire.glsl'

const shader = Shaders.create({
  fire: {
    frag: GLSL`${fire}`,
  },
})

export default function RayMarcher() {
  return <Canvas className="h-screen overflow-hidden" shader={shader.fire} passTickUniform />
}
