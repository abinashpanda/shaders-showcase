import { GLSL, Shaders } from 'gl-react'
import Canvas from 'components/canvas'
import ripple from 'shaders/ripple.glsl'

const shader = Shaders.create({
  ripple: {
    frag: GLSL`${ripple}`,
  },
})

export default function Ripple() {
  return <Canvas className="h-screen" shader={shader.ripple} uniforms={{ uPattern: 'pattern.jpg' }} passTickUniform />
}
