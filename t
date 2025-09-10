// Angular global + modules
import angular from 'angular';
window.angular = angular;
import '@uirouter/angularjs';
import 'angular-animate';
import 'angular-aria';
import 'angular-messages';
import 'angular-sanitize';
import 'angular-resource';
import 'angular-cookies';
import 'angular-translate';
import 'angular-translate-loader-static-files';
import 'angular-material';
import 'angular-material/angular-material.css';

// Toastr + CSS -> global
import toastr from 'toastr';
import 'toastr/build/toastr.css';
window.toastr = toastr;


--------


entry: {
  vendor: path.resolve(__dirname, 'src/vendor.js'),
  app: path.resolve(__dirname, 'src/index.js'),
  templates: path.resolve(__dirname, 'src/index.templates.js'),
},
optimization: {
  splitChunks: {
    cacheGroups: {
      vendor: {
        test: /[\\/]node_modules[\\/]/,
        name: 'vendor',
        chunks: 'all',
        enforce: true,           // force la création du chunk vendor
        reuseExistingChunk: true,
        priority: -10,
      },
    },
  },
  runtimeChunk: 'single',
},
plugins: [
  new HtmlWebpackPlugin({
    template: './src/index.html.ejs',
    chunks: ['runtime', 'vendor', 'app', 'templates'],
    chunksSortMode: 'manual',
    scriptLoading: 'defer',
  }),
],
