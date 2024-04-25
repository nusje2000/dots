function ColorMyPencils(color)
    color = color or "moonfly"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = "#ff5189" })
    vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#80a0ff", bg = "#323437" })
    vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = "#ff5189" })
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#80a0ff", bg = "#323437" })
    vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = "#eeeeee", bg = "#ff5454" })
    vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = "#eeeeee", bg = "#ff5454" })
    vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = "#80a0ff" })
    vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "#323437" })
    vim.api.nvim_set_hl(0, "TelescopePromptNormal", { fg = "#eeeeee", bg = "#323437" })
    vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = "#eeeeee", bg = "#ff5454" })
end

ColorMyPencils()
