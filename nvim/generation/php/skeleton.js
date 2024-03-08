const generateNamespace = require('./namespace')
const { readFileSync } = require('fs')
const { join } = require('path')

module.exports = (file) => {
    if (typeof file !== 'string') {
        throw new Error('Expected file to be a string.')
    }

    const namespace = generateNamespace(file)
    const skeleton = readFileSync(join(__dirname, 'skeleton.php'), 'utf8')

    return skeleton
        .replace('__NAMESPACE__', namespace)
        .replace('__CLASS__', /\/(?<class>[^\/]+).php$/.exec(file).groups?.class)
}
