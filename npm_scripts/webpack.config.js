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
          name (module, chunks, cacheGroupKey) {
              return "" + module + "-" + chunks + "-" + cacheGroupKey;
          },
          chunks: "async",
          minChunks: 2,
          cacheGroups: {
            tinycolor: {
                name: 'mercury-tinycolor',
                test: /[\\/]tinycolor2[\\/]/,
            },
        }
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
      })
  ]
};