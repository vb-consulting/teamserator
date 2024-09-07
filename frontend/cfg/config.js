const path = require("path");
const { parseJsonWithComments } = require("./utils");

const serverConfig = parseJsonWithComments("./backend/cfg/server.json");
const rootPath = serverConfig.StaticFiles.RootPath;
const srcDir = "./frontend/src/";
const assetsDir = path.join(srcDir, "assets/");

module.exports = {
    srcDir,
    rootPath,
    assetsDir,
    rollup: "./frontend/cfg/rollup.config.js",

    bootstrapIconsWoff2: "./node_modules/bootstrap-icons/font/fonts/bootstrap-icons.woff2",
    bootstrapIconsWoff: "./node_modules/bootstrap-icons/font/fonts/bootstrap-icons.woff",
    bootstrapIconTypes: "./node_modules/bootstrap-icons/font/bootstrap-icons.json",
    fontsDir: path.join(assetsDir, "fonts/"),

    iconTypesFileName: path.join(srcDir, "app/lib/_icons.d.ts"),
    styleDir: path.join(srcDir, "style/"),
    styleName: "style", // without extension css or scss
    buildIdCustomHeaderConfigFile: "./backend/cfg/build-id-header.json"
}
