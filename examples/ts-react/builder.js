const webpack = require("webpack")
const fs = require("fs")

const webpackConfig = require("./configs/webpack/dev");

const compiler = webpack(webpackConfig)

const watcher = compiler.watch({}, err => {
    if (err) {
        console.log("error")
        console.log(err)
    }
    else {
        console.log("webpack finished compiling")
    }
})