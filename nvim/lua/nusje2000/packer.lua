-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.5',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }
  use({
      'kadekillary/Turtles',
      as = 'turtles'
  })
  use({
	  'folke/tokyonight.nvim',
	  as = 'tokyonight',
  })
  use({
      'bluz71/vim-moonfly-colors',
      as = 'moonfly'
  })

  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
  use('nvim-treesitter/playground')
  use('tpope/vim-fugitive')
  use('mbbill/undotree')
  use('feline-nvim/feline.nvim')
  use('lewis6991/gitsigns.nvim')
  use('prettier/vim-prettier')
  use('nvim-tree/nvim-tree.lua')
  use('nvim-tree/nvim-web-devicons')
  use('ThePrimeagen/harpoon')
  use('windwp/nvim-ts-autotag')
  use('chaoren/vim-imageview')
  use('hiphish/rainbow-delimiters.nvim')
  use {
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v3.x',
	  requires = {
		  --- Uncomment these if you want to manage LSP servers from neovim
		  {'williamboman/mason.nvim'},
		  {'williamboman/mason-lspconfig.nvim'},

		  -- LSP Support
		  {'neovim/nvim-lspconfig'},
		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'L3MON4D3/LuaSnip'},
	  }
  }
end)
