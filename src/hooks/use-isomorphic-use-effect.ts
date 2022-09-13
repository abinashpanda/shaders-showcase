import { useEffect, useLayoutEffect } from 'react'

export const useIsomorphicUseEffect = typeof window !== 'undefined' ? useLayoutEffect : useEffect
