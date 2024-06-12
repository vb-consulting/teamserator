
const path = require("path");
const { exec } = require("../../frontend/cfg/utils");

module.exports = () => new Promise(resolve => exec("npx npgsqlrest-config-copy ./backend/cfg").then(() => resolve()));

