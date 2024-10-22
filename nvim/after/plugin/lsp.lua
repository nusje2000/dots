local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
local lsp_zero = require('lsp-zero')
local lspconfig = require('lspconfig')

require("luasnip.loaders.from_vscode").lazy_load({
    paths = { vim.fn.stdpath('config') .. '/snippets' }
})

cmp.setup({
    sources = {
        { name = 'luasnip' },
        { name = 'nvim_lsp' },
    },
    mapping = {
        ['<C-f>'] = cmp_action.luasnip_jump_forward(),
        ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
    },
    preselect = 'item',
    completion = {
        completeopt = 'menu,menuone,noinsert'
    },
})

lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    lsp_zero.default_keymaps({ buffer = bufnr })

    vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', { buffer = bufnr })
end)

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        "ts_ls",
        "eslint",
        "lua_ls",
        "rust_analyzer",
        "phpactor"
    },
    handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
            lspconfig.lua_ls.setup({
                capabilities = lsp_capabilities,
                settings = {
                    Lua = {
                        runtime = {
                            version = 'LuaJIT',
                        },
                        diagnostics = {
                            globals = { 'vim' }
                        },
                        workspace = {
                            library = {
                                vim.env.VIMRUNTIME,
                            }
                        }
                    }
                }
            })
        end,
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
