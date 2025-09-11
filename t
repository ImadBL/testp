proxy: [
    {
      context: [
        '/api',
        '/apps/app-cdn',
        '/apps/rest',
        '/amxbpm',
        '/bpm',
        '/bpmresources'
      ],
      target: 'http://localhost:8080',
      changeOrigin: true,
      secure: false,          // utile si backend en HTTPS self-signed
      ws: true,               // si tu as des WebSockets
      logLevel: 'info',
      // pathRewrite: { '^/apps/app-cdn': '/apps/app-cdn' } // seulement si besoin
    }
  ]
