npm i -D eslint eslint-webpack-plugin eslint-plugin-angular
{
  "env": {
    "browser": true,
    "es2021": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:angular/johnpapa"
  ],
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "plugins": [
    "angular"
  ],
  "rules": {
    "no-unused-vars": "warn",
    "no-console": "off",
    "angular/no-service-method": "off"
  }
}

const ESLintPlugin = require('eslint-webpack-plugin');

module.exports = (env, argv) => {
  const isProd = argv.mode === 'production';

  return {
    // ...
    plugins: [
      // autres plugins...
      new ESLintPlugin({
        extensions: ['js'],
        emitWarning: !isProd,   // warnings seulement en dev
        failOnError: isProd     // en prod => build échoue si erreurs
      })
    ]
  };
};


// webpack.config.js
module.exports = {
  // ...
  module: {
    rules: [
      // (ta règle .html reste en premier)
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            // transforme le JS moderne → compatible navigateurs
            presets: [
              ['@babel/preset-env', {
                targets: { esmodules: true }, // ou browsers: 'defaults'
                modules: false               // conserve import/export, Webpack gère
              }]
            ],
            // ajoute automatiquement les $inject
            plugins: [
              ['angularjs-annotate', { explicitOnly: false }]
            ],
            cacheDirectory: true
          }
        }
      }
    ]
  }
};



const isProd = process.env.NODE_ENV === 'production';

module.exports = {
  mode: isProd ? 'production' : 'development',

  // 🔹 Active les source maps uniquement en dev
  devtool: isProd ? false : 'eval-cheap-module-source-map',

  // ...
  optimization: {
    minimize: isProd,
    // tes plugins de minification (Terser, CssMinimizer…)
  },

  // ...
};










const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');

const SRC = path.resolve(__dirname, 'src');
const isProd = process.env.NODE_ENV === 'production';

module.exports = {
  mode: isProd ? 'production' : 'development',

  entry: {
    app: path.join(SRC, 'main.js'),
    template: path.join(SRC, 'templates.js'), // bundle séparé pour les templates
  },

  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: isProd ? 'js/[name].[contenthash:8].js' : 'js/[name].js',
    chunkFilename: isProd ? 'js/[name].[contenthash:8].chunk.js' : 'js/[name].chunk.js',
    publicPath: '/',
    clean: true,
  },

  module: {
    rules: [
      // ---------- TEMPLATES ANGULARJS ----------
      // Place cette règle en PREMIER
      {
        test: /\.html$/i,
        include: [path.join(SRC, 'app')], // cible uniquement tes templates
        issuer: /\.[jt]s$/i,              // importés depuis JS (templates.js, composants, etc.)
        type: 'javascript/auto',
        use: [
          {
            loader: 'ngtemplate-loader',
            options: {
              relativeTo: SRC,            // clés stables dans $templateCache
            },
          },
          {
            loader: 'html-loader',
            options: {
              minimize: true,
              sources: false,             // ne transforme pas <img src>, <link href>...
            },
          },
        ],
      },

      // ---------- HTML index ----------
      // index.html géré par HtmlWebpackPlugin → pas via la règle ci-dessus
      {
        test: /index\.html?$/i,
        include: [SRC],
        use: [
          {
            loader: 'html-loader',
            options: { minimize: isProd, sources: false },
          },
        ],
        type: 'javascript/auto',
      },

      // ---------- CSS ----------
      {
        test: /\.css$/i,
        use: [
          isProd ? MiniCssExtractPlugin.loader : 'style-loader',
          {
            loader: 'css-loader',
            options: { importLoaders: 1, sourceMap: !isProd },
          },
          {
            loader: 'postcss-loader',
            options: { sourceMap: !isProd },
          },
        ],
      },

      // ---------- LESS ----------
      {
        test: /\.less$/i,
        use: [
          isProd ? MiniCssExtractPlugin.loader : 'style-loader',
          {
            loader: 'css-loader',
            options: { importLoaders: 2, sourceMap: !isProd },
          },
          {
            loader: 'postcss-loader',
            options: { sourceMap: !isProd },
          },
          {
            loader: 'less-loader',
            options: {
              sourceMap: !isProd,
              lessOptions: { javascriptEnabled: true },
            },
          },
        ],
      },

      // ---------- Assets ----------
      {
        test: /\.(png|jpe?g|gif|svg|webp|ico)$/i,
        type: 'asset',
        parser: { dataUrlCondition: { maxSize: 8 * 1024 } }, // inline < 8KB
        generator: { filename: 'assets/img/[name].[contenthash:8][ext]' },
      },
      {
        test: /\.(woff2?|eot|ttf|otf)$/i,
        type: 'asset/resource',
        generator: { filename: 'assets/fonts/[name].[contenthash:8][ext]' },
      },

      // ---------- (Optionnel) expose jQuery global ----------
      // {
      //   test: require.resolve('jquery'),
      //   loader: 'expose-loader',
      //   options: { exposes: [{ globalName: '$', override: true }, { globalName: 'jQuery', override: true }] }
      // },
    ],
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: path.join(SRC, 'index.html'), // ton index source
      minify: isProd
        ? {
            collapseWhitespace: true,
            removeComments: true,
            removeRedundantAttributes: true,
            removeEmptyAttributes: true,
            minifyCSS: true,
            minifyJS: true,
          }
        : false,
    }),

    ...(isProd
      ? [new MiniCssExtractPlugin({ filename: 'css/[name].[contenthash:8].css', chunkFilename: 'css/[name].[contenthash:8].css' })]
      : []),
  ],

  optimization: {
    minimize: isProd,
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          compress: { drop_console: true, drop_debugger: true },
          format: { comments: false },
        },
        extractComments: false,
      }),
      new CssMinimizerPlugin(),
    ],
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        angular: {
          test: /[\\/]node_modules[\\/](angular|angular-ui-router|@uirouter)[\\/]/,
          name: 'angular',
          priority: 20,
          enforce: true,
        },
        vendors: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          priority: 10,
        },
      },
    },
    runtimeChunk: 'single',
  },

  devtool: isProd ? false : 'eval-cheap-module-source-map',

  devServer: {
    static: [{ directory: path.resolve(__dirname, 'dist'), publicPath: '/' }],
    historyApiFallback: true,
    hot: true,
    port: 3000,
    open: false,
    proxy: [
      // adapte si besoin
      // { context: ['/api'], target: 'http://localhost:8080', changeOrigin: true }
    ],
  },

  // Pour éviter des effets de cache lors des tests
  // cache: false,
};
