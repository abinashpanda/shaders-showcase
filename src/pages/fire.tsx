import { GLSL, Shaders } from 'gl-react'
import Canvas from 'components/canvas'
import fire from 'shaders/fire.glsl'

const shader = Shaders.create({
  fire: {
    frag: GLSL`${fire}`,
  },
})

export default function App() {
  return <Canvas className="h-screen" shader={shader.fire} />
}
