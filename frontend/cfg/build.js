﻿/***********************************************

Frontend build script for compiling Svelte TypeScript and SCSS files.
It spwans a child process npx rollup and npx scss to compile the files.

Usage:
    node frontend/cfg/build.js [options] [page]
    node frontend/cfg/build.js [options]

- options:
    -w, --watch -watch: watch the files for changes (applies to both rollup and SCSS)
    -s, --style -style: compile only the style files without TypeScript (SCSS located in front/style)
Note: styles are always compiled use -s to compile only styles without TypeScript.

- page: the path to the TypeScript file to compile (relative to front/) like "app/index.ts" without the extension (just use index)
Note: if no page is provided, all TypeScript files in front/ will be compiled.

***********************************************/
const fs = require("fs");
const path = require("path");
const { exec, error, log, info, cpy } = require("./utils");
const { 
    srcDir, 
    assetsDir,
    rootPath, 
    styleName, 
    styleDir, 
    rollup, 
    buildIdCustomHeaderConfigFile 
} = require("./config");

const args = process.argv.slice(2);
const ts = ".ts";

let page = "";
let watch = false;
let style = false;

if (args.length) {
    for (let arg of args) {
        let lower = arg.toLowerCase();
        if (lower == "-w" || lower == "--watch" || lower == "-watch") {
            watch = true;
        } else if (lower == "-s" || lower == "--style" || lower == "-style") {
            style = true;
        } else {
            page = lower;
        }
    }
}

const rollupCmd = "npx rollup -c " + rollup + " " + (watch ? "-w " : "") + "--bundleConfigAsCjs -- ";
const styleCmd = `npx sass ${path.join(styleDir, styleName)}.scss ${path.join(rootPath, styleName)}.css ${watch ? "-w" : "--no-source-map"} --style compressed`;
const promises = [];

if (!fs.existsSync(rootPath)) {
    info(`${rootPath} → created ...`);
    fs.mkdirSync(rootPath);
}

let files = fs.readdirSync(rootPath);
for (let i = 0; i < files.length; i++) {
    var file = path.join(rootPath, files[i]);
    if (file.endsWith(".map")) {
        log("Removing map file " + file + " ...");
        fs.unlinkSync(file);
    }
}

if (!style) {
    if (page) {

        if (!page.startsWith(srcDir)) {
            page = path.join(srcDir, page);
        }
        if (!page.endsWith(ts)) {
            page += ts;
        }
        if (!fs.existsSync(page)) {
            error(`ERROR: Could not find page '${page}'`);
            return;
        }
        promises.push(exec(rollupCmd + page));
        promises.push(exec(styleCmd));

    } else {
        
        if (!fs.existsSync(rootPath)) {
            log("Creating dir " + rootPath + " ...");
            fs.mkdirSync(rootPath);
        } else {
            fs.rmSync(rootPath, { recursive: true, force: true });
            log("Creating dir " + rootPath + " ...");
            fs.mkdirSync(rootPath);
        }

        function copyAssets(dir) {
            let files = fs.readdirSync(dir);
            for(let i = 0; i < files.length; i++) {
                let file = path.join(dir, files[i]);
                if (fs.statSync(file).isDirectory()){
                    copyAssets(file);
                } else {
                    let destPath = path.join(rootPath, path.relative(assetsDir, dir));
                    let dest = path.join(destPath, files[i]);
                    cpy(file, dest, true);
                }
            }
        }
        copyAssets(assetsDir);

        let files = fs.readdirSync(srcDir);
        for (let i = 0; i < files.length; i++) {
            var file = path.join(srcDir, files[i]);
            if (file.endsWith(".ts")) {
                promises.push(exec(rollupCmd + file));
            }
        }

        promises.push(exec(styleCmd));
    }

} else {
    promises.push(exec(styleCmd));
}

if (promises.length) {
    Promise.all(promises).then(
        () => {
            var rnd = (Math.random() + 1).toString(36).substring(2);
            // create new text file build-id-header.json
            fs.writeFileSync(buildIdCustomHeaderConfigFile, [
                "// autogenerated by build.js", 
                JSON.stringify({ NpgsqlRest: {CustomRequestHeaders: {"X-build-id": rnd}} })
            ].join("\n"));
            log("🐶");
        }
    );
}
