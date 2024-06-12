const path = require("path");
const { parseJsonWithComments } = require("./utils");

const serverConfig = parseJsonWithComments("./backend/cfg/appsettings-server.json");
const rootPath = serverConfig.StaticFiles.RootPath;
const srcDir = "./frontend/src/";

module.exports = {
    srcDir,
    rootPath,
    bootstrapIconsWoff2: "./node_modules/bootstrap-icons/font/fonts/bootstrap-icons.woff2",
    bootstrapIconsWoff: "./node_modules/bootstrap-icons/font/fonts/bootstrap-icons.woff",
    bootstrapIconTypes: "./node_modules/bootstrap-icons/font/bootstrap-icons.json",
    fontsDir: path.join(rootPath, "fonts/"),
    iconTypesFileName: path.join(srcDir, "app/lib/_icons.d.ts"),
    styleDir: path.join(srcDir, "style/"),
    styleName: "style", // without extension css or scss
    rollup: "./frontend/cfg/rollup.config.js",
    buildIdCustomHeaderConfigFile: "./backend/cfg/appsettings-build-id-header.json"
}
