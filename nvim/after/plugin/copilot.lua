local chat = require("CopilotChat");

chat.setup {
    mappings = {
        submit_prompt = {
            normal = '<Leader>s',
            insert = '<C-s>'
        },
        reset = {
            normal = '<C-r>',
            insert = '<C-r>',
        },
    }
}

vim.keymap.set('n', '<leader>cc', chat.toggle)
vim.keymap.set('v', '<leader>cc', chat.toggle)
