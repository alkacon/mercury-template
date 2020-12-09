const path = require('path');
const webpack = require('webpack');
const TerserPlugin = require("terser-webpack-plugin");

module.exports = {

  entry: {
      'mercury' : './template-src/js/mercury.js',
  },

  output: {
      path: path.resolve(__dirname, '../build/npm/js'),
      filename: '[name].js'
  },

  optimization: {
      splitChunks: {
          chunks: "async",
          minChunks: 2
      },
      minimize: true,
      minimizer: [
          new TerserPlugin({
              extractComments: false, // prevents the generation of multiple license files
          }),
      ],
  },

  devtool: 'source-map',

  mode: 'production',
  // mode: 'development',

  plugins: [
      new webpack.ProgressPlugin(),
      new webpack.ProvidePlugin({
          // inject jQuery module as global var for Bootstrap, Shariff and other scripts
          $: 'jquery',
          jQuery: 'jquery',
          'window.jQuery': 'jquery'
      }),
      new webpack.DefinePlugin({
          WEBPACK_SCRIPT_VERSION: '"'
              + ((new Date()).toLocaleDateString('de-DE', { formatMatcher : 'basic', year: '2-digit', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' } ))
              + '"'
      }),
  ]
};