function Highlight(name, options)
    vim.api.nvim_set_hl(0, name, options)
end

local moonfly = require("moonfly")

vim.g.moonflyCursorColor = true

moonfly.custom_colors({
--  black = '#ffffff',
--  white = '#ffffff',
--  bg = '#ffffff',
--  grey0 = '#ffffff',
--  grey1 = '#ffffff',
--  grey89 = '#ffffff',
--  grey70 = '#ffffff',
--  grey62 = '#ffffff',
--  grey58 = '#ffffff',
--  grey50 = '#ffffff',
--  grey39 = '#ffffff',
--  grey30 = '#ffffff',
--  grey27 = '#ffffff',
--  grey23 = '#ffffff',
--  grey18 = '#ffffff',
--  grey15 = '#ffffff',
--  grey11 = '#ffffff',
--  grey7 = '#ffffff',
--  khaki = '#ffffff',
--  yellow = '#ffffff',
  orange = '#ed752f',
--  coral = '#ffffff',
  orchid = '#fc798e',
--  lime = '#ffffff',
--  green = '#ffffff',
--  emerald = '#ffffff',
  turquoise = '#6ef3fa',
--  blue = '#ffffff',
  sky = '#329dfa',
  lavender = '#7878f5',
--  purple = '#ffffff',
  violet = '#d55cff',
  cranberry = '#fc425d',
--  crimson = '#ffffff',
--  red = '#ffffff',
--  spring = '#ffffff',
--  mineral = '#ffffff',
--  bay = '#ffffff',
  slate = '#748999'
})

function ColorMyPencils(color)
    color = color or "moonfly"
    vim.cmd.colorscheme(color)

    vim.opt.termguicolors = true
    -- Highlight("Cursor", { fg = "green", bg = "green" })
    -- Highlight("Cursor2", { fg = "red", bg = "red" })
    vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor2/lCursor2,r-cr:hor20,o:hor50"

    Highlight("TelescopeSelection", { link = "MoonflyCrimson" })
    Highlight("TelescopeBorder", { fg = "#80a0ff", bg = nil })
    Highlight("TelescopeMatching", { link = "MoonflyCrimson" })
    Highlight("TelescopePromptBorder", { fg = "#80a0ff", bg = nil })
    Highlight("TelescopeResultsTitle", { fg = "#eeeeee", bg = "#ff5454", bold = true })
    Highlight("TelescopePreviewTitle", { fg = "#eeeeee", bg = "#ff5454", bold = true })
    Highlight("TelescopePromptPrefix", { fg = "#80a0ff", bg = nil })
    Highlight("TelescopeNormal", { bg = nil })
    Highlight("TelescopePromptNormal", { fg = "#eeeeee", bg = nil })
    Highlight("TelescopePromptTitle", { fg = "#eeeeee", bg = "#ff5454", bold = true })
    Highlight("MsgArea", { fg = "#80a0ff", bg = nil, bold = true })

    Highlight("DiagnosticSignWarn", { link = "MoonflyKhaki" })
    Highlight("DiagnosticSignHint", { link = "MoonflyPurple" })
    Highlight("DiagnosticSignInfo", { link = "MoonflyLime" })
    Highlight("DiagnosticSignError", { link = "MoonflyCrimson" })

    Highlight("DiagnosticVirtualTextWarn", { link = "MoonflyKhaki" })
    Highlight("DiagnosticVirtualTextHint", { link = "MoonflyPurple" })
    Highlight("DiagnosticVirtualTextInfo", { link = "MoonflyLime" })
    Highlight("DiagnosticVirtualTextError", { link = "MoonflyCrimson" })

    Highlight("Statusline", { bg = nil })
    Highlight("StatusLineNC", { bg = nil })
    Highlight("WinSeparator", { fg = "#444444" })

    Highlight("@string", { link = "MoonflyEmerald" })
end

ColorMyPencils()
