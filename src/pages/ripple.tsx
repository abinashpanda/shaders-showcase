import { GLSL, Shaders } from 'gl-react'
import Canvas from 'components/canvas'
import ripple from 'shaders/ripple.glsl'
import { useRef, useState } from 'react'
import { getImageSize } from 'utils/image'
import { useIsomorphicUseEffect } from 'hooks/use-isomorphic-use-effect'

const shader = Shaders.create({
  ripple: {
    frag: GLSL`${ripple}`,
  },
})

const IMAGE =
  'https://images.unsplash.com/photo-1590593162201-f67611a18b87?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=730&q=80'

export default function Ripple() {
  const [patternAspectRatio, setPatternAspectRatio] = useState<number>(0)
  useIsomorphicUseEffect(function getPatternAspectRatio() {
    if (typeof window !== 'undefined') {
      getImageSize(IMAGE).then(({ aspectRatio }) => {
        setPatternAspectRatio(aspectRatio)
      })
    }
  }, [])

  const position = useRef<{ x: number; y: number }>({ x: 0, y: 0 })
  const [positionState, setPositionState] = useState<[number, number]>([0, 0])
  const targetPosition = useRef<{ x: number; y: number }>({ x: 0, y: 0 })
  useIsomorphicUseEffect(function setInitialPositionState() {
    if (typeof window !== 'undefined') {
      position.current.x = window.innerWidth / 2
      position.current.y = window.innerHeight / 2
      targetPosition.current.x = window.innerWidth / 2
      targetPosition.current.y = window.innerHeight / 2
      setPositionState([window.innerWidth / 2.0, window.innerHeight / 2.0])
    }
  }, [])

  const velocity = useRef<{ x: number; y: number }>({ x: 0, y: 0 })
  useIsomorphicUseEffect(function listenToMouseMove() {
    function handleMouseMove(event: MouseEvent) {
      targetPosition.current = { x: event.clientX, y: event.clientY }
    }

    if (typeof window !== 'undefined') {
      window.addEventListener('mousemove', handleMouseMove)
    }

    return () => {
      if (typeof window !== 'undefined') {
        window.removeEventListener('mousemove', handleMouseMove)
      }
    }
  }, [])

  useIsomorphicUseEffect(function updatePosition() {
    let raf: number | undefined

    function handleAnimation() {
      position.current.x += velocity.current.x
      position.current.y += velocity.current.y

      velocity.current.x = (targetPosition.current.x - position.current.x) * 0.05
      velocity.current.y = (targetPosition.current.y - position.current.y) * 0.05

      setPositionState([position.current.x, position.current.y])

      if (typeof window !== 'undefined') {
        raf = window.requestAnimationFrame(handleAnimation)
      }
    }

    if (typeof window !== 'undefined') {
      raf = window.requestAnimationFrame(handleAnimation)
    }

    return () => {
      if (typeof window !== 'undefined' && typeof raf !== 'undefined') {
        window.cancelAnimationFrame(raf)
      }
    }
  }, [])

  return (
    <>
      <Canvas
        className="h-screen overflow-hidden cursor-none"
        shader={shader.ripple}
        uniforms={{
          uPattern: IMAGE,
          uPatternAspectRatio: patternAspectRatio,
          uCenter: positionState,
        }}
        passTickUniform
        passAspectRatioUniform
        passResolutionUniform
        passMouseUniform={false}
      />
    </>
  )
}
