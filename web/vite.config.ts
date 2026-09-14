import vue from '@vitejs/plugin-vue'
import { defineConfig } from 'vite'
import Components from 'unplugin-vue-components/vite'
import Icons from 'unplugin-icons/vite'
import IconsResolve from 'unplugin-icons/resolver'

export default defineConfig({
  plugins: [
    vue(),
    Components({
      resolvers: [IconsResolve()],
      dts: false,
    }),
    Icons({
      compiler: 'vue3',
      autoInstall: true,
    }),
  ],
  optimizeDeps: {
    include: [
      'feather-icons',
      'highlight.js',
      'highlight.js/lib/core',
      'interactjs',
      'lowlight',
      'sortablejs',
      'debug',
    ],
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:8000',
        changeOrigin: false,
        headers: {
          Host: 'analytics.localhost:8000',
        },
      },
    },
  },
})