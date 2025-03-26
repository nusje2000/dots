const path = require("path");
const fs = require("fs");
const php = require("../generation/php");
const bash = require("../generation/bash");

const [language, command, ...arguments] = process.argv.slice(2);

const commands = {
    general: {},
    php,
    sh: bash,
};

commands.general.attemptSkeleton = (file) => {
    const lang = path.extname(file).replace(/^\./, "");
    const generateSkeleton = commands[lang]?.generateSkeleton;

    if (!generateSkeleton) {
        return;
    }

    try {
        const skeleton = generateSkeleton(file);
        fs.writeFileSync(file, skeleton);
    } catch (e) {
        console.error(e);
    }
};

const func = commands[language][command] ?? null;
if (!func) {
    throw new Error(
        `Could not execute command ${command} for language ${language}`
    );
}

console.log(func(...arguments));
