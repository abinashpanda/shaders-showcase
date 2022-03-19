import clsx from 'clsx'
import { Surface } from 'gl-react-dom'
import { Node } from 'gl-react'
import type { ShaderDefinition, ShaderIdentifier } from 'gl-react'
import { useTimeLoop } from 'hooks/use-time-loop'
import { useRef, useState } from 'react'
import useMeasure from 'react-use-measure'

type CanvasProps = {
  shader: ShaderDefinition | ShaderIdentifier
  uniforms?: { [key: string]: any }
  passTickUniform?: boolean
  className?: string
  style?: React.CSSProperties
}

export default function Canvas({ shader, uniforms = {}, passTickUniform = false, className, style }: CanvasProps) {
  const [measure, measurements] = useMeasure()

  const { time, tick } = useTimeLoop(60, passTickUniform)

  const hasClicked = useRef(false)
  const [mousePos, setMousePos] = useState([0, 0])

  return (
    <div
      className={clsx(className)}
      style={style}
      ref={measure}
      onMouseDown={(event) => {
        hasClicked.current = true
        setMousePos([event.clientX - measurements.x, event.clientY - measurements.y])
      }}
      onMouseUp={() => {
        hasClicked.current = false
      }}
      onMouseMove={(event) => {
        if (hasClicked.current) {
          setMousePos([event.clientX - measurements.x, event.clientY - measurements.y])
        }
      }}
    >
      <Surface width={measurements.width} height={measurements.height}>
        <Node
          shader={shader}
          uniforms={{
            uAspectRatio: measurements.width / measurements.height,
            uResolution: [measurements.width, measurements.height],
            uMouse: mousePos,
            ...uniforms,
            ...(passTickUniform ? { uTick: tick, uTime: time } : {}),
          }}
        />
      </Surface>
    </div>
  )
}
