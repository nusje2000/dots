local lsp_zero = require('lsp-zero')
local lspconfig = require('lspconfig')

lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    lsp_zero.default_keymaps({ buffer = bufnr })

    vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', { buffer = bufnr })
end)

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        "tsserver",
        "eslint",
        "lua_ls",
        "rust_analyzer",
        "phpactor"
    },
    handlers = {
        lsp_zero.default_setup,
    },
})

vim.keymap.set('n', '<C-Space>', vim.lsp.buf.code_action)

lsp_zero.set_sign_icons({
    error = '✘',
    warn = '',
    hint = '󰟶',
    info = '»'
})

local diagnostic_prefixes = {
  [vim.diagnostic.severity.ERROR] = '✘',
  [vim.diagnostic.severity.WARN] = '',
  [vim.diagnostic.severity.HINT] = '󰟶',
  default = '»',
}

vim.diagnostic.config({
    virtual_text = {
        prefix = "",
        spacing = 1,
        format = function(diagnostic)
            return string.format(
                "%s %s",
                diagnostic_prefixes[diagnostic.severity]
                or diagnostic_prefixes.default,
                diagnostic.message
            )
        end
    },
})
