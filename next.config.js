/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: false,
  webpack: (config) => {
    return {
      ...config,
      module: {
        ...config.module,
        rules: [
          ...config.module.rules,
          {
            test: /\.glsl/,
            loader: 'raw-loader',
          },
        ],
      },
    }
  },
}

module.exports = nextConfig
