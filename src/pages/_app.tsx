import 'styles/tailwind.css'
import type { AppProps } from 'next/app'
import Head from 'next/head'

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <Head>
        <title>Shaders Showcase</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/svg+xml" href="favicon.svg" />
      </Head>
      <Component {...pageProps} />
    </>
  )
}

export default MyApp
