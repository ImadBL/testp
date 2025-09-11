devServer: {
  static: {
    directory: path.resolve(__dirname, 'dist'), // ou SRC_DIR si tu veux
  },
  port: 3000,
  hot: true, // équivalent livereload
  proxy: {
    '/api': {
      target: 'http://localhost:8080', // ton backend
      changeOrigin: true,
    },
    '/apps/app-cdn': {
      target: 'http://localhost:8080',
      changeOrigin: true,
    },
    '/apps/rest': {
      target: 'http://localhost:8080',
      changeOrigin: true,
    },
    '/amxbpm': {
      target: 'http://localhost:8080',
      changeOrigin: true,
    },
    '/bpm': {
      target: 'http://localhost:8080',
      changeOrigin: true,
    },
    '/bpmresources': {
      target: 'http://localhost:8080',
      changeOrigin: true,
    },
  },
}
