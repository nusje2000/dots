local builtin = require('telescope.builtin')
local themes = require('telescope.themes')
local telescope = require('telescope')

-- Resolve the superproject root so searches aren't rooted at a git submodule
-- (e.g. `lando`) when the active buffer lives inside one.
local function project_root()
    local super = vim.fn.systemlist({ 'git', 'rev-parse', '--show-superproject-working-tree' })[1]
    if super and super ~= '' then
        return super
    end
    return vim.fn.systemlist({ 'git', 'rev-parse', '--show-toplevel' })[1]
end

local project_files = function()
    local root = project_root()
    local ok = pcall(require 'telescope.builtin'.git_files, { cwd = root })
    if not ok then
        require 'telescope.builtin'.find_files({
            cwd = root,
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        })
    end
end

local all_files = function()
    require 'telescope.builtin'.find_files({
        cwd = project_root(),
        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*", "--no-ignore-vcs" },
    })
end

local line_border = { '━', '┃', '━', '┃', '┏', '┓', '┛', '┗' }
local thick_border = { '▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' }

local layout_strategies = require('telescope.pickers.layout_strategies')

layout_strategies.under_line = function(self, max_columns, max_lines, layout_config)
    local layout = layout_strategies.cursor(self, max_columns, max_lines, layout_config)
    local win_pos = vim.api.nvim_win_get_position(self.original_win_id)
    local left = win_pos[2]

    layout.prompt.col = left
    layout.results.col = left
    if layout.preview then layout.preview.col = left end
    return layout
end

telescope.setup {
    defaults = {
        prompt_prefix = "   ",
        selection_caret = " ",
        use_less = true,
        borderchars = line_border,
        preview = {
            filesize_limit = 1
        },
    },
    pickers = {
        find_files = {}
    },
    extensions = {
        ['ui-select'] = {
            themes.get_cursor({
                layout_strategy = 'under_line',
                layout_config   = { width = 60, height = 10 },
                prompt_title    = 'Code Actions',
                borderchars     = line_border,
                previewer       = false,
            }),
        },
    },
}

telescope.load_extension('harpoon')
telescope.load_extension('notify')
telescope.load_extension('dap')
telescope.load_extension('ui-select')

vim.keymap.set('n', '<leader>pf', all_files, {})
vim.keymap.set('n', '<leader>gf', project_files, {})
vim.keymap.set('n', '<leader>dd', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>ds', builtin.lsp_dynamic_workspace_symbols, {})
vim.keymap.set('n', '<leader>sr', function() vim.cmd('Telescope resume') end)
vim.keymap.set('n', '<leader>gs', function()
    builtin.live_grep({
        cwd = project_root(),
        additional_args = { "--hidden" }
    });
end)
vim.keymap.set('n', '<leader>ps', function()
    builtin.live_grep({
        cwd = project_root(),
        additional_args = { "--hidden", "--no-ignore-vcs" }
    });
end)

vim.keymap.set('n', '<leader>ha', require('harpoon.mark').add_file)
vim.keymap.set('n', '<leader>hc', require('harpoon.mark').clear_all)
vim.keymap.set('n', '<leader>hh', function() vim.cmd('Telescope harpoon marks') end)
vim.keymap.set('n', '<leader>hp', function() vim.cmd('Telescope planets') end)
