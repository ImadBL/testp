new CopyWebpackPlugin({
  patterns: [
    // i18n + favicon, tu avais déjà
    { from: path.join(SRC, 'i18n'), to: 'i18n' },
    { from: path.join(SRC, 'assets', 'favicon.ico'), to: 'favicon.ico', noErrorOnMissing: true },

    // => copie TOUTES les vues sous dist/app/... en gardant l'arborescence
    {
      from: path.join(SRC, 'app', '**/*.html'),
      to({ absoluteFilename }) {
        // remet le chemin relatif à src/ (conserve "app/...")
        return path.relative(SRC, absoluteFilename).replace(/\\/g, '/');
      },
      noErrorOnMissing: false,
    },
  ],
}),
