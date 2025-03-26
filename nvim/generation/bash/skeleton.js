const { readFileSync } = require("fs");
const { join } = require("path");

module.exports = (file) => {
    if (typeof file !== "string") {
        throw new Error("Expected file to be a string.");
    }

    return readFileSync(join(__dirname, "skeleton.sh"), "utf8");
};
