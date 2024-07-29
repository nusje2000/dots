const path = require('path')
const fs = require('fs')
const { getComposerDirectory } = require('./composer')


function generateNamespace(file) {
    const rootPath = getComposerDirectory(file)
    const composerDefinition = JSON.parse(
        fs.readFileSync(
            path.join(rootPath, 'composer.json')
        )
    ) 

    const autoloadDefinitions = [
        ...Object.entries(composerDefinition?.autoload?.['psr-4'] ?? {}),
        ...Object.entries(composerDefinition?.['autoload-dev']?.['psr-4'] ?? []),
    ] 

    const [baseNamespace, relPath] = autoloadDefinitions.find(
        ([_, relPath]) => file.startsWith(path.join(rootPath, relPath))
    )

    return (baseNamespace + path.relative(
        path.join(rootPath, relPath),
        path.dirname(file)
    )).replace('/', '\\')
}

module.exports = generateNamespace
