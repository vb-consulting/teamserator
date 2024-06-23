const fs = require("fs");
const path = require("path");
const cp = require('child_process');

function parseJsonWithComments(filename) {
    var code = fs.readFileSync(filename, 'utf8')
        .toString()
        .replace(/\/\*[\s\S]*?\*\/|([^:]|^)\/\/.*$/gm, '$1')
        .replace(/(^|\s)\/\/(?!\S*:\/\/)/g, '')
        .trim();
    return JSON.parse(code);
}

const error = msg => console.error("\x1b[31m" + msg + "\x1b[0m");
const log = msg => console.log("\x1b[36m" + msg + "\x1b[0m");
const info = log;

function exec(cmd) {
    return new Promise(resolve => {
        log(cmd);
        let exec = cp.exec(cmd)
        exec.stdout.on("data", data => { if (data) { log(data.trim()); } });
        exec.stderr.on("data", data => { if (data) { error(data.trim()); } });
        exec.on("exit", () => resolve());
    });
}

function cpy(from, to, parseHtml) {
    if (!fs.existsSync(from)) {
        error(`ERROR: Could not find file '${from}'`);
        return;
    }
    if (!fs.existsSync(to)) {
        fs.mkdirSync(path.dirname(to), { recursive: true });
    }
    info(`${from} → ${to}...`);
    if (parseHtml && from.endsWith('.html')) {
        var rnd = (Math.random() + 1).toString(36).substring(2);
        let content = fs.readFileSync(from, 'utf8').replace(/\.css"|\.js"/g, function(match) {
            return match.replace('"', `?${rnd}"`);
        });
        fs.writeFileSync(to, content);
    } else {
        fs.copyFileSync(from, to);
    }
}

module.exports = {
    parseJsonWithComments,
    exec,
    cpy,
    error,
    log,
    info
}
