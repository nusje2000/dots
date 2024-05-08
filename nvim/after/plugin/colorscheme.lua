function Highlight(name, options)
    vim.api.nvim_set_hl(0, name, options)
end

function ColorMyPencils(color)
    color = color or "moonfly"
    vim.cmd.colorscheme(color)

    Highlight("TelescopeSelection", { fg = "#ff5189" })
    Highlight("TelescopeBorder", { fg = "#80a0ff", bg = "#323437" })
    Highlight("TelescopeMatching", { fg = "#ff5189" })
    Highlight("TelescopePromptBorder", { fg = "#80a0ff", bg = "#323437" })
    Highlight("TelescopeResultsTitle", { fg = "#eeeeee", bg = "#ff5454", bold = true })
    Highlight("TelescopePreviewTitle", { fg = "#eeeeee", bg = "#ff5454", bold = true })
    Highlight("TelescopePromptPrefix", { fg = "#80a0ff" })
    Highlight("TelescopeNormal", { bg = "#323437" })
    Highlight("TelescopePromptNormal", { fg = "#eeeeee", bg = "#323437" })
    Highlight("TelescopePromptTitle", { fg = "#eeeeee", bg = "#ff5454", bold = true })
    Highlight("MsgArea", { fg = "#80a0ff", bg = "#323437", bold = true })

    Highlight("DiagnosticSignWarn", { fg = "#c6c684" })
    Highlight("DiagnosticSignHint", { fg = "#ae81ff" })
    Highlight("DiagnosticSignInfo", { fg = "#85dc85" })
    Highlight("DiagnosticSignError", { fg = "#ff5189" })

    Highlight("DiagnosticVirtualTextWarn", { fg = "#c6c684" })
    Highlight("DiagnosticVirtualTextHint", { fg = "#ae81ff" })
    Highlight("DiagnosticVirtualTextInfo", { fg = "#85dc85" })
    Highlight("DiagnosticVirtualTextError", { fg = "#ff5189" })

    Highlight("@string", { fg = "#cf87e8" })
end

ColorMyPencils()
