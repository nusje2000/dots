vim.wo.relativenumber = true
vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = false
vim.opt.wrap = false

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.opt.listchars = {
    space ="•"
}
vim.opt.fillchars = {
    eob =" ",
}

vim.opt.undolevels=1000
vim.opt.undoreload=10000

vim.opt.lazyredraw = true -- Improve redraw performance
vim.opt.synmaxcol = 300   -- Limit syntax highlighting columns

vim.g.mapleader = " "
vim.g.moonflyTransparent = true

-- Force garbage collection every 10 minutes
vim.cmd([[autocmd CursorHold * lua collectgarbage("collect")]])
