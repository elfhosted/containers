import { resolve } from 'node:path'
import { viteFastify } from '@fastify/vite/plugin'
import viteReact from '@vitejs/plugin-react'

/** @type {import('vite').UserConfig} */
export default {
  base: '/app/',
  root: resolve(import.meta.dirname, 'src/client'),
  plugins: [viteReact(), viteFastify()],
  cacheDir: '/tmp/vite-cache', // ⚡ Fix: Set cache to writable location
  build: {
    outDir: resolve(import.meta.dirname, 'dist/client'),
    emptyOutDir: false,
    assetsInclude: ['**/*.woff2', '**/*.woff'],
  },
  resolve: {
    alias: {
      '@': resolve(import.meta.dirname, 'src/client'),
      '@root': resolve(import.meta.dirname, 'src'),
    },
  },
}
