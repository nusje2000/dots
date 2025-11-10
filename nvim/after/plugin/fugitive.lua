vim.keymap.set('n', '<leader>gg', vim.cmd.Git, { })
vim.keymap.set('n', '<leader>gp', ':G push', { })
vim.keymap.set('n', '<leader>gbn', ':G checkout -B ', { })
vim.keymap.set('n', '<leader>gbc', ':G checkout ', { })
vim.keymap.set('n', '<leader>gP', ':G push --force-with-lease', { })
vim.keymap.set('n', '<leader>gl', ':G log --oneline<cr>', { })

vim.keymap.set('n', '<leader>gr', function()
    vim.cmd(string.format(
        ':G rebase -i HEAD~%d',
        vim.fn.input("Commit count > ")
    ))
end)
