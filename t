npm i -D mini-css-extract-plugin css-loader postcss postcss-loader autoprefixer \
less less-loader css-minimizer-webpack-plugin \
svgspritemap-webpack-plugin


const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CssMinimizerPlugin   = require('css-minimizer-webpack-plugin');
const SVGSpritemapPlugin   = require('svgspritemap-webpack-plugin');
const path = require('path');

module.exports = (env, argv) => {
  const isProd = argv.mode === 'production';

  return {
    // ...
    module: {
      rules: [
        // CSS / LESS (équiv. cleanCSS + less() + concat)
        {
          test: /\.(css|less)$/i,
          use: [
            MiniCssExtractPlugin.loader,     // extrait en fichiers
            {
              loader: 'css-loader',
              options: {
                sourceMap: !isProd,
                // équiv. urlAdjuster: laisse css-loader rebaser les urls()
                url: true,
                importLoaders: 1              // laisse passer postcss sur @import
              }
            },
            {
              loader: 'postcss-loader',
              options: {
                sourceMap: !isProd,
                postcssOptions: {
                  plugins: [require('autoprefixer')()]
                }
              }
            },
            {
              loader: 'less-loader',
              options: { sourceMap: !isProd }
            }
          ]
        },

        // Fonts (otf,eot,svg,ttf,woff,woff2) – équiv. task fonts
        {
          test: /\.(otf|eot|svg|ttf|woff|woff2)$/i,
          type: 'asset/resource',
          generator: {
            filename: 'assets/fonts/[name][ext]'  // dist/assets/fonts/...
          }
        },

        // Images (jpg/png/gif/svg* hors sprite) – équiv. task images
        {
          test: /\.(png|jpe?g|gif)$/i,
          type: 'asset/resource',
          generator: {
            filename: 'assets/imgs/[name][ext]'
          }
        },
      ]
    },

    plugins: [
      // Extrait vendor.css et app.less en 2 fichiers distincts
      new MiniCssExtractPlugin({
        filename: 'assets/css/[name].[contenthash:8].min.css'
      }),

      // Sprite SVG (équiv. gulp svgSprite -> icons.svg)
      new SVGSpritemapPlugin('src/assets/imgs/svg/*.svg', {
        output: {
          filename: 'assets/imgs/icons.svg'
        },
        sprite: {
          prefix: false,         // symbol ids = nom de fichier
          generate: { title: false }
        }
      })
    ],

    optimization: {
      minimize: isProd,
      minimizer: [
        '...',                   // Terser (JS) reste actif
        new CssMinimizerPlugin() // minify CSS (équiv. cleanCSS)
      ],
      splitChunks: {
        chunks: 'all'
      }
    }
  };
};


const CopyWebpackPlugin = require('copy-webpack-plugin');

new CopyWebpackPlugin({
  patterns: [
    { from: 'src/assets/favicon.ico', to: 'assets/favicon.ico' }
  ]
})


// eslint.config.cjs
const js = require('@eslint/js');
const angular = require('eslint-plugin-angular');

module.exports = [
  // --- Ignorer complètement certains fichiers ou dossiers ---
  {
    ignores: [
      'dist/**',
      'node_modules/**',
      // désactive totalement le lint sur ces deux fichiers :
      'src/main.js',
      'src/templates.js',
    ],
  },

  // --- Base recommandée ---
  js.configs.recommended,

  // --- Règles pour TOUT ton code app ---
  {
    files: ['src/app/**/*.js'],     // 👈 lint SEULEMENT sous src/app/**
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
    },
    plugins: { angular },
    rules: {
      'no-unused-vars': 'warn',
      'no-console': 'off',
      'angular/no-service-method': 'off',
    },
  },

  // --- (Option) GARDER templates.js mais autoriser require ---
  // Dé-commente ce bloc si tu veux linter src/templates.js au lieu de l'ignorer.
  // {
  //   files: ['src/templates.js'],
  //   languageOptions: {
  //     ecmaVersion: 'latest',
  //     sourceType: 'module',
  //     globals: {
  //       require: 'readonly' // pour require.context(...)
  //     }
  //   },
  //   rules: {}
  // }
];






const js = require("@eslint/js");
const angular = require("eslint-plugin-angular");

module.exports = [
  js.configs.recommended,
  {
    files: ["src/**/*.js"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module"
    },
    plugins: {
      angular
    },
    rules: {
      "no-unused-vars": "warn",
      "no-console": "off",
      "angular/controller-as": "off",
      "angular/no-service-method": "off"
    }
  }
];



// src/core/services/example.service.spec.js
import angular from 'angular';
import 'angular-mocks';
import '../app.module'; // ton module principal

describe('exampleService', () => {
  let exampleService, $rootScope;

  beforeEach(angular.mock.module('app')); // nom de ton module
  beforeEach(inject((_exampleService_, _$rootScope_) => {
    exampleService = _exampleService_;
    $rootScope = _$rootScope_;
  }));

  it('should return value', () => {
    expect(exampleService.get()).toBeDefined();
  });
});



// karma.conf.js
const path = require('path');

module.exports = function (config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine'],

    files: [
      // AngularJS + mocks (si tu ne les importes pas via webpack dans les tests)
      require.resolve('angular/angular.js'),
      require.resolve('angular-mocks/angular-mocks.js'),

      // Tes tests
      { pattern: 'src/**/*.spec.js', watched: false }
    ],

    preprocessors: {
      'src/**/*.spec.js': ['webpack', 'sourcemap']
    },

    webpack: {
      mode: 'development',
      devtool: 'inline-source-map',
      module: {
        rules: [
          // charge les templates si tu les testes
          {
            test: /\.html$/i,
            use: [{ loader: 'html-loader', options: { sources: false, esModule: false } }]
          },
          // Babel (si tu l’utilises dans le projet)
          {
            test: /\.js$/,
            exclude: /node_modules/,
            use: {
              loader: 'babel-loader',
              options: {
                presets: [['@babel/preset-env', { modules: false }]],
                plugins: [
                  // pour la couverture
                  ['istanbul', { exclude: ['**/*.spec.js', '**/tests/**'] }]
                ]
              }
            }
          }
        ]
      },
      resolve: { extensions: ['.js'] }
    },

    reporters: ['spec', 'coverage'],
    coverageReporter: {
      dir: path.join(__dirname, 'coverage'),
      reporters: [
        { type: 'html', subdir: 'html' },
        { type: 'text-summary' },
        { type: 'lcov', subdir: '.' }
      ]
    },

    browsers: ['ChromeHeadless'],
    singleRun: true,   // true pour CI, false pour watch
    specReporter: { suppressPassed: false, suppressSkipped: true },
    client: { clearContext: false },
    webpackMiddleware: { stats: 'errors-only' }
  });
};


npm i -D karma karma-jasmine jasmine-core \
karma-chrome-launcher karma-webpack karma-sourcemap-loader karma-spec-reporter \
karma-coverage \
angular-mocks
# (si tu utilises Babel)
npm i -D @babel/core @babel/preset-env babel-loader babel-plugin-istanbul








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
