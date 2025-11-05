local theme = require 'lualine.themes.moonfly'
theme.inactive.c.bg = nil
theme.normal.c.bg = nil
theme.normal.b.bg = nil

local function dap()
    if require('dap').session() == nil then
        return ''
    end

    return '<F5>   <F10>   <F11>   <F12>   <L>ds ';
end

function isRecording()
  local reg = vim.fn.reg_recording()
  if reg == "" then return "" end -- not recording
  return "󰑊 " .. reg
end

require('lualine').setup({
    options = {
        icons_enabled = true,
        theme = theme,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename', dap, isRecording },
        lualine_x = { 'encoding', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
    inactive_sections = {
        lualine_a = { 'filename' },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
})
