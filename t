const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');

module.exports = {
  // ...
  plugins: [
    new BundleAnalyzerPlugin()
  ],
};


stats: {
  chunks: true,
  modules: true,
  reasons: true,
}
