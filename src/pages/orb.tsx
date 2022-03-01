import { GLSL, Shaders } from 'gl-react'
import Canvas from 'components/canvas'
import orb from 'shaders/orb.glsl'

const shader = Shaders.create({
  orb: {
    frag: GLSL`${orb}`,
  },
})

export default function App() {
  return <Canvas className="h-screen" shader={shader.orb} />
}
