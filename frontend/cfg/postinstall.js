/***********************************************

NPM postinstall script:
- Copies the bootstrap icons to the fonts directory.
- Creates a TypeScript file with the types of the bootstrap icons.
- Creates a rootPath dir (wwwroot) if it does not exist.

***********************************************/
const fs = require("fs");
const path = require("path");
const { cpy, info } = require("./utils");
const {
    bootstrapIconsWoff2, 
    bootstrapIconsWoff, 
    bootstrapIconTypes, 
    fontsDir, 
    iconTypesFileName, 
    rootPath
} = require("./config");

module.exports = () => new Promise(resolve => {
    cpy(bootstrapIconsWoff2, `${fontsDir}${path.basename(bootstrapIconsWoff2)}`);
    cpy(bootstrapIconsWoff, `${fontsDir}${path.basename(bootstrapIconsWoff)}`);
    
    if (iconTypesFileName) {
        console.log("\x1b[36m" + `Creating file ${iconTypesFileName} ...`);
        const content = [];
        content.push("// auto generated");
        
        //bootstrap icons:
        if (bootstrapIconTypes) {
            //console.log(JSON.parse(fs.readFileSync(bootstrapIconTypes, 'utf8')));
            content.push("");
            content.push("type BootstrapIconsType =");
            for(var item of Object.keys(JSON.parse(fs.readFileSync(bootstrapIconTypes, 'utf8')))) {
                content.push(`    | "${item}"`);
            }
            content[content.length - 1] = content[content.length - 1] + ";";
        }
    
        //create iconTypesFileName file from content lines
        if (!fs.existsSync(iconTypesFileName)) {
            fs.mkdirSync(path.dirname(iconTypesFileName), { recursive: true });
        }
        fs.writeFileSync(iconTypesFileName, content.join("\n"));
        info(`${iconTypesFileName} → created ...`);
    }
    if (!fs.existsSync(rootPath)) {
        info(`${rootPath} → created ...`);
        fs.mkdirSync(rootPath);
    }
    resolve();
});


