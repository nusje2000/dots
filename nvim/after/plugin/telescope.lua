local builtin = require('telescope.builtin')
local telescope = require('telescope')

local project_files = function()
    local opts = {
        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" }
    }

    local ok = pcall(require 'telescope.builtin'.git_files, opts)
    if not ok then
        require 'telescope.builtin'.find_files(opts)
    end
end

telescope.setup {
    pickers = {
        find_files = {
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*", "--no-ignore-vcs" }
        }
    }
}

telescope.load_extension('harpoon')

vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>gf', project_files, {})
vim.keymap.set('n', '<leader>dd', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)

vim.keymap.set('n', '<leader>ha', require('harpoon.mark').add_file)
vim.keymap.set('n', '<leader>hc', require('harpoon.mark').clear_all)
vim.keymap.set('n', '<leader>hh', function() vim.cmd('Telescope harpoon marks') end)
