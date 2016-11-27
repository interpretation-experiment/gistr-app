var historyApiFallback = require('connect-history-api-fallback');
var browserSync = require("browser-sync").create();

browserSync.init({
    files: ["build/*"],
    reloadDelay: 500,
    server: {
        baseDir: "build",
        middleware: [ historyApiFallback() ]
    }
});
