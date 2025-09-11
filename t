// webpack.config.js
module.exports = {
  // ...
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: [
          { loader: 'babel-loader', options: { presets: ['@babel/preset-env'], plugins: ['angularjs-annotate'] } },
          { loader: 'ng-annotate-loader', options: { add: true, es6: true } }
        ]
      }
    ]
  },
  optimization: { minimize: true },
};
---------
