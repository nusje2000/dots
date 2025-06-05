require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "typescript", "javascript", "html", "css", "php" },
    sync_install = false,
    auto_install = true,
    autotag = {
        enable = true,
    },
    indent = {
        enable = true,
    },
    highlight = {
        enable = true,
        disable = function(lang, buf)
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > 800 * 1024 then
                return true
            end

            return false
        end,
        additional_vim_regex_highlighting = false,
    },
}
