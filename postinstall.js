const { log } = require("./frontend/cfg/utils");
const frontend = require("./frontend/cfg/postinstall");
const backend = require("./backend/cfg/postinstall");

Promise.all([frontend(), backend()]).then(() => log("🐶"));

