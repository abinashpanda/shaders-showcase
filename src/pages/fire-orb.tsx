import { GLSL, Shaders } from 'gl-react'
import Canvas from 'components/canvas'
import rayMarcher from 'shaders/fire-orb.glsl'

const shader = Shaders.create({
  rayMarcher: {
    frag: GLSL`${rayMarcher}`,
  },
})

export default function App() {
  return <Canvas className="h-screen" shader={shader.rayMarcher} />
}
