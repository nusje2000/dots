local builtin = require('telescope.builtin')
local telescope = require('telescope')

local project_files = function()
    local opts = {
        find_command = { "rg", "--follow", "--files", "--hidden", "--glob", "!**/.git/*" }
    }

    local ok = pcall(require 'telescope.builtin'.git_files, opts)
    if not ok then
        require 'telescope.builtin'.find_files(opts)
    end
end

local all_files = function()
    local opts = {
        find_command = { "rg", "--follow", "--files", "--hidden", "--glob", "!**/.git/*", "--no-ignore-vcs" }
    }

    require 'telescope.builtin'.find_files(opts)
end

local line_border = { '━', '┃', '━', '┃', '┏', '┓', '┛', '┗' }
local thick_border = { '▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' }
telescope.setup {
    defaults = {
        prompt_prefix = "   ",
        selection_caret = " ",
        use_less = true,
        borderchars = line_border,
    },
    pickers = {
        find_files = {}
    }
}

telescope.load_extension('harpoon')

vim.keymap.set('n', '<leader>pf', all_files, {})
vim.keymap.set('n', '<leader>gf', project_files, {})
vim.keymap.set('n', '<leader>dd', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>gs', function()
    builtin.grep_string({
        search = vim.fn.input("Grep > "),
        additional_args = { "--follow", "--hidden" }
    });
end)
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({
        search = vim.fn.input("Grep > "),
        additional_args  = { "--follow", "--hidden", "--no-ignore-vcs" }
    });
end)

vim.keymap.set('n', '<leader>ha', require('harpoon.mark').add_file)
vim.keymap.set('n', '<leader>hc', require('harpoon.mark').clear_all)
vim.keymap.set('n', '<leader>hh', function() vim.cmd('Telescope harpoon marks') end)
