vim.keymap.set('t', '<Esc>', "<C-\\><C-n>")
vim.keymap.set('n', '<leader>m', function () vim.cmd('split') vim.cmd('terminal btop') end)

vim.keymap.set('n', '<leader>q', vim.cmd.quit)
vim.keymap.set('n', '<leader>t', vim.cmd.tabnew)
vim.keymap.set('n', '<leader>T', vim.cmd.tabclose)
vim.keymap.set('n', '<A-l>', vim.cmd.tabnext)
vim.keymap.set('n', '<A-h>', vim.cmd.tabprevious)

vim.keymap.set('n', '<C-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>')
