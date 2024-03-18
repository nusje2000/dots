require('gitsigns').setup({
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        vim.keymap.set('n', '<leader>hn', gs.next_hunk)
        vim.keymap.set('n', '<leader>hr', gs.reset_hunk)
        vim.keymap.set('n', '<leader>hs', gs.stage_hunk)
        vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk)
        vim.keymap.set('n', '<leader>hR', gs.reset_buffer)
        vim.keymap.set('n', '<leader>hp', gs.preview_hunk)
        vim.keymap.set('n', '<leader>hd', gs.toggle_deleted)
        vim.keymap.set('n', '<leader>gb', gs.toggle_current_line_blame)
    end
})
