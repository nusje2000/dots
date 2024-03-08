vim.keymap.set('n', '<leader>gg', vim.cmd.Git, { })
vim.keymap.set('n', '<leader>gp', ':G push', { })
vim.keymap.set('n', '<leader>gP', ':G push --force-with-lease', { })
