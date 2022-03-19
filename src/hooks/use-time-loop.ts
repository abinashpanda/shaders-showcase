import { useEffect, useRef, useState } from 'react'

export function useTimeLoop(refreshRate: number = 60, runTimer: boolean = true) {
  const [time, setTime] = useState(0)
  const [tick, setTick] = useState(0)

  const raf = useRef<number | null>(null)

  useEffect(
    function runLoop() {
      const interval = 1000 / refreshRate

      let startTime: number
      let lastTime = -interval

      function loop(time: number) {
        if (runTimer) {
          raf.current = requestAnimationFrame(loop)
        }
        if (!startTime) {
          startTime = time
        }
        if (time - lastTime > interval) {
          lastTime = time
          setTime(time - startTime)
          setTick((nextState) => nextState + 1)
        }
      }

      raf.current = requestAnimationFrame(loop)

      return () => {
        if (raf.current !== null) {
          cancelAnimationFrame(raf.current)
        }
      }
    },
    [refreshRate, runTimer],
  )

  return { time, tick }
}
