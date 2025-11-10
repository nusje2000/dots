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

vim.lsp.config('pylsp', {
    settings = {
        pylsp = {
            plugins = {
                pylint = { enabled = false },
                pycodestyle = { enabled = false },
            }
        }
    }
})

lsp_zero.on_attach(function(_, bufnr)
    local map = function(m, lhs, rhs, desc)
        local key_opts = { buffer = bufnr, desc = desc, nowait = true }
        vim.keymap.set(m, lhs, rhs, key_opts)
    end

    map('n', 'gr', '<cmd>Telescope lsp_references<cr>', 'Show references')
    map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', 'Go to definition')
    map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', 'Go to declaration')
    map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', 'Go to implementation')
    map('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', 'Go to type definition')
    map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', 'Go to reference')
    map('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol')
    map('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', 'Execute code action')
    map('n', 'g?', '<cmd>lua vim.diagnostic.open_float()<cr>', 'Execute code action')
    map('n', '<F3>', function()
        vim.lsp.buf.format({
            filter = function(client)
                print(client.name)

                local formatter_file = vim.fn.findfile('.nvim-formatters', vim.fn.getcwd() .. ';')
                if formatter_file == '' then
                    return true
                end


                local formatters = {}
                for line in io.lines(formatter_file) do
                    formatters[line] = true
                end

                return formatters[client.name] ~= nil
            end,
            bufnr = bufnr
        })
    end)
end)

require('mason').setup()
require('mason-lspconfig').setup({
    automatic_enable = true,
    ensure_installed = {},
})

vim.lsp.config('lua_ls', {
  root_markers = { '.clang-format', 'compile_commands.json' },
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

vim.lsp.config('phpactor', {
    root_markers = {'composer.lock', '.git'}
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
    virtual_lines = false,
})
