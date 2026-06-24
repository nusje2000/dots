-- OctoberCMS uses the .htm extension for Twig templates (pages, layouts,
-- partials, mail views). Neovim defaults .htm to `html`, which leaves Twig
-- tags ({% %}, {{ }}) and the <x-...> component tags unhighlighted. Scope the
-- override to October's directory layout so plain .htm HTML files elsewhere
-- keep the html filetype.
vim.filetype.add({
    pattern = {
        ['.*/themes/.*%.htm'] = 'twig',
        ['.*/plugins/.*%.htm'] = 'twig',
    },
})
