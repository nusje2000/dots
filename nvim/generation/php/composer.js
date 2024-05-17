const path = require('path')
const fs = require('fs')

module.exports = {
    getComposerDirectory: (fileOrDirectory) => {
        if (!path.isAbsolute(fileOrDirectory)) {
            throw new Error(`File path must be an absolute path, ${fileOrDirectory} given.`)
        }

        let rootPath = fileOrDirectory
        while (rootPath !== '/' && !fs.existsSync(path.join(rootPath, 'composer.json'))) {
           rootPath = path.dirname(rootPath) 
        }

        if (!rootPath) {
            throw new Error(`Could not locate composer rootPath for ${file}`)
        }

        return rootPath
    } 
}
