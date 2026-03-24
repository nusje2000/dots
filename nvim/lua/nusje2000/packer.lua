-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = 'v0.2.*',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    use({
        'bluz71/vim-moonfly-colors',
        as = 'moonfly'
    })

    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use('tpope/vim-fugitive')
    use('mbbill/undotree')
    use('github/copilot.vim')
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }
    use('lewis6991/gitsigns.nvim')
    use('prettier/vim-prettier')
    use('nvim-tree/nvim-tree.lua')
    use('nvim-tree/nvim-web-devicons')
    use('ThePrimeagen/harpoon')
    use('chaoren/vim-imageview')
    use('hiphish/rainbow-delimiters.nvim')
    use({
        'hrsh7th/nvim-cmp',
        commit = 'b356f2c80cb6c5bae2a65d7f9c82dd5c3fdd6038',
    })
    use({
        'MeanderingProgrammer/render-markdown.nvim',
        after = { 'nvim-treesitter' },
        requires = { 'nvim-tree/nvim-web-devicons', opt = true },
        config = function()
            require('render-markdown').setup({
                completions = { lsp = { enabled = true } },
                checkbox = {
                    enabled = true,
                    unchecked = {
                        icon = '󰄱 ',
                    },
                    checked = {
                        icon = '󰱒 ',
                    },
                },
            })
        end,
    })
    use({
        "mason-org/mason-lspconfig.nvim",
        tag = "v2.1.*",
        opts = {},
        requires = {
            { "mason-org/mason.nvim", opts = {} },
            { "neovim/nvim-lspconfig", tag = "v2.5.*" },
        }
    })
    use({
        "folke/noice.nvim",
        requires = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        }
    })
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'L3MON4D3/LuaSnip' },
        }
    }
    use({
        "L3MON4D3/LuaSnip",
        tag = "v2.*",
        run = "make install_jsregexp"
    })
    use({
        "saadparwaiz1/cmp_luasnip"
    })

    use({
        'nvimdev/lspsaga.nvim',
        after = 'nvim-lspconfig',
        config = function()
            require('lspsaga').setup({
                lightbulb = {
                    enable = false
                },
                ui = {
                    border = 'rounded',
                    code_action = ' ',
                    devicon = false,
                    kind = {},
                },
                code_action = {
                    show_server_name = false,
                    num_shortcut = true,
                },
            })
        end,
    })

    -- php debugger
    use('mfussenegger/nvim-dap')
    use('rcarriga/nvim-dap-ui')
    use('theHamsta/nvim-dap-virtual-text')
    use('nvim-telescope/telescope-dap.nvim')
end)
