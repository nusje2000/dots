local api = require("nvim-tree.api")

local mark_quicklist = function()
    local marks = api.marks.list()
    local qf_entries = {}

    for _, mark in ipairs(marks) do
        table.insert(qf_entries, {
            filename = mark.absolute_path,
            lnum = mark.line,
        })
    end

    vim.fn.setqflist(qf_entries, "r")
    vim.cmd("copen")

    api.marks.clear()
    api.tree.reload()
end

local search_files_in_selected_dir = function()
    local node = api.tree.get_node_under_cursor()
    if node and node.absolute_path then
        vim.cmd("Telescope find_files cwd=" .. node.absolute_path)
    end
end

local grep_files_in_selected_dir = function()
    local node = api.tree.get_node_under_cursor()
    if node and node.absolute_path then
        vim.cmd("Telescope live_grep cwd=" .. node.absolute_path)
    end
end

local copy_file_path = function()
    local node = api.tree.get_node_under_cursor()
    if node and node.absolute_path then
        local file_name = vim.fn.fnamemodify(node.absolute_path, ":t")
        local relative_path = vim.fn.fnamemodify(node.absolute_path, ":.")
        local absolute_path = node.absolute_path

        local options = {
            { label = "File Name", value = file_name },
            { label = "Relative Path", value = relative_path },
            { label = "Absolute Path", value = absolute_path },
        }

        vim.ui.select(options, {
            prompt = "Select item to copy",
            format_item = function(item)
                return item.label
            end,
        }, function(choice)
            if choice then
                vim.fn.setreg('+', choice.value)
                print("Copied to clipboard: " .. choice.value)
            end
        end)
    end
end

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
    on_attach = function(bufnr)
        local api = require("nvim-tree.api")

        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.set('n', '<C-q>', mark_quicklist)
        vim.keymap.set('n', '<leader>f', search_files_in_selected_dir, { buffer = bufnr, desc = "Search in selected directory" })
        vim.keymap.set('n', '<leader>s', grep_files_in_selected_dir, { buffer = bufnr, desc = "Grep in selected directory" })
        vim.keymap.set('n', '<leader>cp', copy_file_path, { buffer = bufnr, desc = "Copy the selected file path" })
    end,
})

vim.keymap.set("n", "<leader>pv", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<leader>pp", vim.cmd.NvimTreeFindFile)

local api = require("nvim-tree.api")
local Event = api.events.Event

api.events.subscribe(Event.FileCreated, function(data)
    vim.fn.system("node ~/.config/nvim/bin/generate.js general attemptSkeleton " .. data.fname)
end)
