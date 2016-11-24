var path = require('path');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var HtmlWebpackPlugin = require('html-webpack-plugin');

var extractVendorCss = new ExtractTextPlugin({ filename: 'vendor.css', allChunks: true });

module.exports = function(env) {
  return {
    entry: {
      app: [
        './src/index.js'
      ]
    },

    output: {
      path: path.resolve(__dirname + '/dist'),
      filename: '[name]-[chunkhash].js',
    },

    module: {
      loaders: [
        {
          test: /\.css$/,
          loader: extractVendorCss.extract('css-loader'),
        },
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          loaders: ['elm-hot-loader', 'elm-webpack-loader?verbose=true&warn=true&debug=true'],
        },
      ],

      noParse: /\.elm$/,
    },

    plugins: [
      extractVendorCss,
      new HtmlWebpackPlugin({ template: 'src/index.html' })
    ],

    devServer: {
      inline: true,
      historyApiFallback: true,
      stats: 'errors-only',
    },
  }
};
