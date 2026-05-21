local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
local lsp_zero = require('lsp-zero')

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
    map('n', 'gd', '<cmd>Lspsaga goto_definition<cr>', 'Go to definition')
    map('n', 'gD', '<cmd>Lspsaga goto_type_definition<cr>', 'Go to declaration')
    map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', 'Go to implementation')
    map('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', 'Go to type definition')
    map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', 'Go to reference')
    map('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol')
    map('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', 'Execute code action')
    map('n', 'g?', '<cmd>lua vim.diagnostic.open_float()<cr>', 'Execute code action')
    map('n', 'K', '<cmd>Lspsaga hover_doc<cr>')
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

vim.lsp.config('yamlls', {
    settings = {
        yaml = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://json.schemastore.org/github-action.json"] = "action.{yml,yaml}",
                ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
                ["https://json.schemastore.org/helmfile.json"] = "helmfile.{yml,yaml}",
                ["https://json.schemastore.org/chart.json"] = "Chart.{yml,yaml}",
                ["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.{yml,yaml}",
                ["https://json.schemastore.org/dependabot-2.0.json"] = ".github/dependabot.{yml,yaml}",
                ["https://json.schemastore.org/gitlab-ci.json"] = "*.gitlab-ci.{yml,yaml}",
                kubernetes = {"k8s/apps/*.yml", "k8s/apps/*.yaml", "k8s/infra/*.yml", "k8s/infra/*.yaml", "k8s/**/templates/*.yml", "k8s/**/templates/*.yaml" },
            },
            schemaStore = {
                enable = false,
                url = "",
            },
            validate = true,
            completion = true,
            hover = true,
        },
    },
})

vim.lsp.config('helm-ls', {
    settings = {
        ['helm-ls'] = {
            yamlls = {
                path = "yaml-language-server",
            }
        }
    },
})

vim.lsp.config('phpactor', {
    root_markers = {'composer.lock', '.git'}
})

vim.lsp.config('biome', {
    cmd = { 'biome', 'lsp-proxy' },
})

vim.lsp.config('csharp_ls', {
    root_markers = {'*.csproj'}
})

vim.keymap.set('n', '<C-Space>', '<cmd>Lspsaga code_action<cr>')

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
