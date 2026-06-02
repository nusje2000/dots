vim.keymap.set('n', '<leader>gg', vim.cmd.Git, { })
vim.keymap.set('n', '<leader>gp', ':G push', { })
vim.keymap.set('n', '<leader>gbn', ':G checkout -B ', { })
vim.keymap.set('n', '<leader>gbc', ':G checkout ', { })
vim.keymap.set('n', '<leader>gP', ':G push --force-with-lease', { })
vim.keymap.set('n', '<leader>gl', ':G log --oneline<cr>', { })

local function reveal_dir_or_default(fugitive_default)
    local ok, cfile = pcall(vim.fn['fugitive#PorcelainCfile'])
    if ok and cfile and cfile ~= '' then
        local path = (cfile:gsub('\\(.)', '%1'))
        if vim.fn.isdirectory(path) == 1 then
            require('nvim-tree.api').tree.find_file({
                buf = vim.fn.fnamemodify(path, ':p'),
                open = true,
                focus = true,
            })
            return
        end
    end

    if fugitive_default then
        local keys = vim.api.nvim_replace_termcodes(fugitive_default, true, false, true)
        vim.api.nvim_feedkeys(keys, 'n', false)
    end
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'fugitive',
    callback = function(event)
        local fugitive_default
        vim.api.nvim_buf_call(event.buf, function()
            local existing = vim.fn.maparg('<CR>', 'n', false, true)
            if existing and existing.rhs and existing.rhs ~= '' then
                fugitive_default = (existing.rhs:gsub('<SID>', '<SNR>' .. existing.sid .. '_'))
            end
        end)

        vim.keymap.set('n', '<CR>', function()
            reveal_dir_or_default(fugitive_default)
        end, { buffer = event.buf, silent = true, desc = 'Reveal directory in nvim-tree, else fugitive default' })
    end,
})

vim.keymap.set('n', '<leader>gr', function()
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    require('telescope.builtin').git_commits({
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                    vim.cmd('G rebase -i ' .. selection.value .. '^')
                end
            end)
            return true
        end,
    })
end)
