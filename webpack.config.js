var path = require("path");

module.exports = {
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
        test:    /\.css$/,
        exclude: /node_modules/,
        loader:  'css-loader',
      },
      {
        test:    /\.html$/,
        exclude: /node_modules/,
        loader:  'file-loader?name=[name].[ext]',
      },
      {
        test:    /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader:  'elm-hot-loader!elm-webpack-loader?verbose=true&warn=true&debug=true',
      },
    ],

    noParse: /\.elm$/,
  },

  devServer: {
    inline: true,
    historyApiFallback: true,
    stats: 'errors-only',
  },

};
