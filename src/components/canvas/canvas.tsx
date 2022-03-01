import clsx from 'clsx'
import { Surface } from 'gl-react-dom'
import { Node } from 'gl-react'
import type { ShaderDefinition, ShaderIdentifier } from 'gl-react'
import { useTimeLoop } from 'hooks/use-time-loop'
import { useState } from 'react'
import useMeasure from 'react-use-measure'

type CanvasProps = {
  shader: ShaderDefinition | ShaderIdentifier
  className?: string
  style?: React.CSSProperties
}

export default function Canvas({ shader, className, style }: CanvasProps) {
  const [measure, measurements] = useMeasure()

  const { time, tick } = useTimeLoop()
  const [mousePos, setMousePos] = useState([0, 0])

  return (
    <div
      className={clsx(className)}
      style={style}
      ref={measure}
      onMouseMove={(event) => {
        setMousePos([event.clientX - measurements.x, event.clientY - measurements.y])
      }}
    >
      <Surface width={measurements.width} height={measurements.height}>
        <Node
          shader={shader}
          uniforms={{
            uAspectRatio: measurements.width / measurements.height,
            uResolution: [measurements.width, measurements.height],
            uTime: time,
            uTick: tick,
            uMouse: mousePos,
          }}
        />
      </Surface>
    </div>
  )
}