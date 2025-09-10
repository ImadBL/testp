devServer: {
  static: { directory: path.join(__dirname, 'dist') },
  port: 3000,
  open: true,
  historyApiFallback: true,
  proxy: [
    // /apps/wfcUI/api  → target + réécriture en /api
    {
      context: ['/apps/wfcUI/api'],
      target: 'https://wfc-apa-d.leasingsolutions.rb.echonet',
      changeOrigin: false,
      secure: false,
      logLevel: 'debug',
      pathRewrite: { '^/apps/wfcUI/api': '/api' },
      onProxyRes(proxyRes) {
        if (proxyRes.headers['location']) {
          proxyRes.headers['location'] =
            proxyRes.headers['location'].replace('https:', 'http:');
        }
      }
    },
    // les autres proxys 1:1 (pas de rewrite)
    {
      context: ['/apps/app-cdn'],
      target: 'https://wfc-apa-d.leasingsolutions.rb.echonet',
      changeOrigin: false,
      secure: false,
      logLevel: 'debug'
    },
    {
      context: ['/apps/rest'],
      target: 'https://wfc-apa-d.leasingsolutions.rb.echonet',
      changeOrigin: false,
      secure: false,
      logLevel: 'debug'
    },
    {
      context: ['/amxbpm'],
      target: 'https://wfc-apa-d.leasingsolutions.rb.echonet',
      changeOrigin: false,
      secure: false,
      logLevel: 'debug'
    },
    {
      context: ['/bpm'],
      target: 'https://wfc-apa-d.leasingsolutions.rb.echonet',
      changeOrigin: false,
      secure: false,
      logLevel: 'debug'
    },
    {
      context: ['/bpmresources'],
      target: 'https://wfc-apa-d.leasingsolutions.rb.echonet',
      changeOrigin: false,
      secure: false,
      logLevel: 'debug'
    }
  ]
}
