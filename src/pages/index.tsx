import { GLSL, Shaders } from 'gl-react'
import Canvas from 'components/canvas'
import simple from 'shaders/simple.glsl'

const shader = Shaders.create({
  simple: {
    frag: GLSL`${simple}`,
  },
})

export default function App() {
  return <Canvas className="h-screen" shader={shader.simple} />
}
