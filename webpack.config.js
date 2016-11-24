var path = require('path');
var ExtractTextPlugin = require('extract-text-webpack-plugin');

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
      filename: '[name].js',
    },

    module: {
      loaders: [
        {
          test: /\.css$/,
          loader: extractVendorCss.extract('css-loader'),
        },
        {
          test: /\.html$/,
          exclude: /node_modules/,
          loader: 'file-loader?name=[name].[ext]',
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
      extractVendorCss
    ],

    devServer: {
      inline: true,
      historyApiFallback: true,
      stats: 'errors-only',
    },
  }
};
