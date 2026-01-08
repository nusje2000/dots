local M = {}

-- Split text into words based on detected casing
local function split_into_words(text)
    -- Handle snake_case and UPPER_SNAKE_CASE
    if text:find('_') then
        local words = {}
        for word in text:gmatch('[^_]+') do
            table.insert(words, word:lower())
        end
        return words
    end

    -- Handle kebab-case
    if text:find('-') then
        local words = {}
        for word in text:gmatch('[^-]+') do
            table.insert(words, word:lower())
        end
        return words
    end

    -- Handle camelCase and PascalCase
    local words = {}
    local current_word = ''
    for i = 1, #text do
        local char = text:sub(i, i)
        if char:match('%u') and #current_word > 0 then
            table.insert(words, current_word:lower())
            current_word = char
        else
            current_word = current_word .. char
        end
    end
    if #current_word > 0 then
        table.insert(words, current_word:lower())
    end
    return words
end

-- Convert words to specific casing
local function to_lower_snake_case(words)
    return table.concat(words, '_')
end

local function to_upper_snake_case(words)
    local upper_words = {}
    for _, word in ipairs(words) do
        table.insert(upper_words, word:upper())
    end
    return table.concat(upper_words, '_')
end

local function to_camel_case(words)
    local result = words[1] or ''
    for i = 2, #words do
        result = result .. words[i]:sub(1, 1):upper() .. words[i]:sub(2)
    end
    return result
end

local function to_pascal_case(words)
    local parts = {}
    for _, word in ipairs(words) do
        if #word > 0 then
            local first = string.upper(string.sub(word, 1, 1))
            local rest = string.sub(word, 2)
            table.insert(parts, first .. rest)
        end
    end
    return table.concat(parts)
end

local function to_kebab_case(words)
    return table.concat(words, '-')
end

local converters = {
    ['lower_snake_case'] = to_lower_snake_case,
    ['UPPER_SNAKE_CASE'] = to_upper_snake_case,
    ['camelCase'] = to_camel_case,
    ['PascalCase'] = to_pascal_case,
    ['kebab-case'] = to_kebab_case,
}

local function convert_text(text, target_casing)
    -- Preserve leading and trailing whitespace
    local leading = text:match('^(%s*)')
    local trailing = text:match('(%s*)$')
    local trimmed = text:match('^%s*(.-)%s*$')

    if #trimmed == 0 then
        return text
    end

    local words = split_into_words(trimmed)
    local converter = converters[target_casing]
    if converter then
        return leading .. converter(words) .. trailing
    end
    return text
end

function M.convert_selection()
    -- Get visual selection
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line = start_pos[2]
    local end_line = end_pos[2]
    local start_col = start_pos[3]
    local end_col = end_pos[3]

    -- Get selected lines
    local lines = vim.fn.getline(start_line, end_line)
    if type(lines) == 'string' then
        lines = { lines }
    end

    -- For single line, extract only the selected portion
    if start_line == end_line then
        lines[1] = lines[1]:sub(start_col, end_col)
    else
        lines[1] = lines[1]:sub(start_col)
        lines[#lines] = lines[#lines]:sub(1, end_col)
    end

    -- Show selection dialog
    local options = {
        'lower_snake_case',
        'UPPER_SNAKE_CASE',
        'camelCase',
        'PascalCase',
        'kebab-case',
    }

    vim.ui.select(options, {
        prompt = 'Convert to:',
    }, function(choice)
        if not choice then
            return
        end

        -- Re-get positions (they may have changed)
        start_pos = vim.fn.getpos("'<")
        end_pos = vim.fn.getpos("'>")
        start_line = start_pos[2]
        end_line = end_pos[2]
        start_col = start_pos[3]
        end_col = end_pos[3]

        -- Process each line
        for i = start_line, end_line do
            local line = vim.fn.getline(i)
            local line_start_col = (i == start_line) and start_col or 1
            local line_end_col = (i == end_line) and end_col or #line

            local before = line:sub(1, line_start_col - 1)
            local selected = line:sub(line_start_col, line_end_col)
            local after = line:sub(line_end_col + 1)

            local converted = convert_text(selected, choice)
            vim.fn.setline(i, before .. converted .. after)
        end
    end)
end

-- Set up keymap
vim.keymap.set('v', '<leader>C', function()
    -- Exit visual mode to set '< and '> marks
    local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
    vim.api.nvim_feedkeys(esc, 'x', false)
    vim.schedule(M.convert_selection)
end, { desc = 'Convert casing' })

return M
