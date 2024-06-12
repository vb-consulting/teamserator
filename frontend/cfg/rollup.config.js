import svelte from "rollup-plugin-svelte";
import commonjs from "@rollup/plugin-commonjs";
import resolve from "@rollup/plugin-node-resolve";
import terser from "@rollup/plugin-terser";
import sveltePreprocess from "svelte-preprocess";
import typescript from "@rollup/plugin-typescript";
import css from "rollup-plugin-css-only";
import replace from '@rollup/plugin-replace';
import alias from "@rollup/plugin-alias";
import path from "path";

const { rootPath } = require("./config");

const production = !process.env.ROLLUP_WATCH;

const getName = str => {
    var split; 
    if (str.includes("\\")) {
        split = str.split("\\");
    }
    else if (str.includes("/")) {
        split = str.split("/");
    }
    return (split[split.length - 1].split(".")[0]);
}

export default args => {
    if (!args["input"] || args["input"].length === 0) {
        throw new Error("No input file specified. Use npx rollup -c [or -w] rollup.config.js --bundleConfigAsCjs -- [input ts file path]");
    }

    const input = args["input"][0];
    const appObject = getName(input);
    const cssOutput = appObject + ".css";
    const globals = {};

    return {
        input: input,
        output: {
            sourcemap: !production,
            format: "iife",
            dir: rootPath,
            name: appObject,
            globals: globals || {}
        },
        plugins: [
            alias({
                entries: [
                    { find: "$lib", replacement:  path.resolve(__dirname, "../src/app/lib") },
                    { find: "$api", replacement:  path.resolve(__dirname, "../src/app/api") },
                    { find: "$part", replacement:  path.resolve(__dirname, "../src/app/part") },
                ]
            }),
            replace({
                preventAssignment: true,
                "process.env.NODE_ENV": JSON.stringify("development")
            }),
            svelte({
                preprocess: sveltePreprocess({ sourceMap: !production }),
                compilerOptions: {
                    // enable run-time checks when not in production
                    dev: !production,
                    customElement: false,
                }
            }),
            // we"ll extract any component CSS out into
            // a separate file - better for performance
            css({ output: cssOutput }),

            // If you have external dependencies installed from
            // npm, you"ll most likely need these plugins. In
            // some cases you"ll need additional configuration -
            // consult the documentation for details:
            // https://github.com/rollup/plugins/tree/master/packages/commonjs
            resolve({
                browser: true,
                dedupe: ["svelte"]
            }),
            commonjs({ 
                sourceMap: !production 
            }),
            typescript({
                sourceMap: !production,
                inlineSources: !production,
                types: ["svelte"],
                resolveJsonModule: true
            }),

            // If we"re building for production (npm run build
            // instead of npm run dev), minify
            production && terser()
        ],
        watch: {
            clearScreen: false
        }
    };
}