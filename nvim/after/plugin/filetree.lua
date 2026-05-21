-- Remove redundant `api` if the first instance is sufficient
local api = require("nvim-tree.api")

local function get_repo_url()
    local repo_url_command = io.popen("git config --get remote.origin.url")
    local repo_url = repo_url_command:read("*a"):gsub("\n", ""):gsub("\\n", "")
    if not repo_url:find("github.com") then
        return nil
    end
    repo_url = repo_url:gsub("git@github.com:", "https://github.com/"):gsub("%.git", "")
    repo_url_command:close()

    return repo_url .. "/blob/main/"
end

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

        -- Assuming GitHub repository URL and branch details
        local repo_url = get_repo_url()
        local options = {
            { label = "File Name",     value = file_name },
            { label = "Relative Path", value = relative_path },
            { label = "Absolute Path", value = absolute_path },
        }

        if repo_url then
            local github_link = repo_url .. relative_path
            table.insert(options, { label = "GitHub Link", value = github_link })
        end

        vim.ui.select(options, {
            prompt = "Select item to copy",
            format_item = function(item)
                return item.label .. " (" .. item.value .. ")"
            end,
        }, function(choice)
            if choice then
                vim.fn.setreg('+', choice.value)
                print("Copied to clipboard: " .. choice.value)
            end
        end)
    end
end

local function clipboard_has_image()
    local output = vim.fn.system("osascript -e 'clipboard info'")
    return output:find("«class PNGf»") ~= nil or output:find("«class TIFF»") ~= nil
end

local function get_dir_for_node(node)
    if node and node.type == "directory" then
        return node.absolute_path
    elseif node and node.absolute_path then
        return vim.fn.fnamemodify(node.absolute_path, ":h")
    end
    return nil
end

local paste_image_from_clipboard = function()
    local node = api.tree.get_node_under_cursor()
    local dir = get_dir_for_node(node)
    if not dir then return end

    if not clipboard_has_image() then
        api.fs.paste()
        return
    end

    if vim.fn.executable("pngpaste") ~= 1 then
        vim.notify("pngpaste is required: brew install pngpaste", vim.log.levels.ERROR)
        return
    end

    vim.ui.select({ "Paste image from clipboard", "Paste file (default)" }, {
        prompt = "Clipboard contains an image:",
    }, function(choice)
        if not choice then return end

        if choice:find("default") then
            api.fs.paste()
            return
        end

        vim.ui.input({ prompt = "Image filename: ", default = "image.png" }, function(filename)
            if not filename or filename == "" then return end

            if not filename:match("%.%w+$") then
                filename = filename .. ".png"
            end

            local filepath = dir .. "/" .. filename
            local result = vim.fn.system({ "pngpaste", filepath })
            if vim.v.shell_error ~= 0 then
                vim.notify("Failed to paste image: " .. result, vim.log.levels.ERROR)
            else
                vim.notify("Saved image to " .. filepath)
                api.tree.reload()
            end
        end)
    end)
end

local preview_file = function()
    -- Run the "preview" console commmand to open the file in the default application
    -- Usage: preview <file_path>
    local node = api.tree.get_node_under_cursor()
    if node and node.absolute_path then
        local file_path = node.absolute_path
        vim.fn.system("preview " .. file_path)
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
        vim.keymap.set('n', '<leader>f', search_files_in_selected_dir,
            { buffer = bufnr, desc = "Search in selected directory" })
        vim.keymap.set('n', '<leader>s', grep_files_in_selected_dir,
            { buffer = bufnr, desc = "Grep in selected directory" })
        vim.keymap.set('n', '<leader>cp', copy_file_path, { buffer = bufnr, desc = "Copy the selected file path" })
        vim.keymap.set('n', '<leader>o', preview_file, { buffer = bufnr, desc = "Preview file" })
        vim.keymap.set('n', 'p', paste_image_from_clipboard, { buffer = bufnr, desc = "Paste (with image support)" })
    end,
})

vim.keymap.set("n", "<leader>pv", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<leader>pp", vim.cmd.NvimTreeFindFile)

local api = require("nvim-tree.api")
local Event = api.events.Event

api.events.subscribe(Event.FileCreated, function(data)
    vim.fn.system("node ~/.config/nvim/bin/generate.js general attemptSkeleton " .. data.fname)
end)
