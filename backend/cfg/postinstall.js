
const fs = require("fs");
const { exec } = require("../../frontend/cfg/utils");

module.exports = () => new Promise(resolve => {
    if (fs.existsSync("./node_modules/npgsqlrest/")) {
        exec("npx npgsqlrest-config-copy ./backend/cfg").then(() => resolve());
    } else {
        resolve();
    }
});

