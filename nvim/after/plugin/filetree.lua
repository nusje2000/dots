require("nvim-tree").setup({
    renderer = {
        full_name = true,
        group_empty = true,
        special_files = {},
        symlink_destination = true,
        indent_markers = {
            enable = true,
        },
        icons = {
            git_placement = "signcolumn",
            show = {
                file = true,
                git = false,
            },
        },
    },
    actions = {
        open_file = {
            quit_on_open = true,
        }
    },
    view = {
        width = '20%',
    },
    filters = {
        dotfiles = false,
    },
})

vim.keymap.set("n", "<leader>pv", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<leader>pp", vim.cmd.NvimTreeFindFile)

local api = require("nvim-tree.api")
local Event = api.events.Event

api.events.subscribe(Event.FileCreated, function(data)
    vim.fn.system("node ~/.config/nvim/bin/generate.js general attemptSkeleton " .. data.fname)
end)
