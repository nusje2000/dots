-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    use({
        'bluz71/vim-moonfly-colors',
        as = 'moonfly'
    })

    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use('nvim-treesitter/playground')
    use('tpope/vim-fugitive')
    use('mbbill/undotree')
    use('github/copilot.vim')
    use {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "github/copilot.vim" },
            { "nvim-lua/plenary.nvim", branch = "master" },
        },
        build = "make tiktoken",
        opts = {
        },
    }
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
            require('render-markdown').setup({})
        end,
    })
    use({
        "yetone/avante.nvim",
        branch = 'main',
        run = 'make',
        config = function()
            require('copilot').setup()
            require('avante').setup({
                instructions_file = "avante.md",
                provider = "copilot",
                providers = {
                    copilot = {
                          endpoint = "https://api.githubcopilot.com",
                          model = "gpt-4o-2024-11-20",
                    }
                }
            })
        end,
        requires = {
            { "nvim-lua/plenary.nvim" },
            { "MunifTanjim/nui.nvim" },
            { 'hrsh7th/nvim-cmp' },
            { "nvim-tree/nvim-web-devicons" },
            { "MeanderingProgrammer/render-markdown.nvim" },
            { "zbirenbaum/copilot.lua" }
        }
    })
    use({
        "mason-org/mason-lspconfig.nvim",
        opts = {},
        requires = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
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

    -- php debugger
    use('mfussenegger/nvim-dap')
    use('rcarriga/nvim-dap-ui')
    use('theHamsta/nvim-dap-virtual-text')
    use('nvim-telescope/telescope-dap.nvim')
end)
