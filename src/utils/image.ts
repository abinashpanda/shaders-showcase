export async function getImageSize(imagePath: string): Promise<{ width: number; height: number; aspectRatio: number }> {
  if (typeof window === 'undefined') {
    throw new Error('getImageSize can only be used in the browser')
  }
  return new Promise((resolve, reject) => {
    const image = new Image()
    image.src = imagePath
    image.addEventListener('load', () => {
      resolve({
        width: image.naturalWidth,
        height: image.naturalHeight,
        aspectRatio: image.naturalWidth / image.naturalHeight,
      })
    })
    image.addEventListener('error', (error) => {
      reject(error)
    })
  })
}
