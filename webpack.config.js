module.exports = {
  entry: "./src/entry.coffee",
  output: {
    path: "./",
    filename: "bundle.js"
  },
  devtool: "source-map",
  resolve: {
    extensions: [".js", ".coffee"],
    modules: ["src", "node_modules"]
  },
  module: {
    rules: [
      {
        test: /\.coffee$/,
        exclude: /(node_modules|bower_components)/,
        use: ["coffee-loader"]
      }
    ]
  }
}