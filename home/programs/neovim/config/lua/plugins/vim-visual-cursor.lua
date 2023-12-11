-- VS Code like keymaps for multiple cursor
vim.cmd([[
    let g:VM_show_warnings = 0 " Disable warnings since some keymaps collide with this plugin
    let g:VM_maps = {}
    let g:VM_maps['Find Under'] = '<C-d>'               " VS Code like Ctrl-d
    let g:VM_maps['Find Subword Under'] = '<C-d>'
    let g:VM_maps["Select Cursor Down"] = '<A-S-J>'     " start selecting down
    let g:VM_maps["Select Cursor Up"]   = '<A-S-K>'     " start selecting up
]])
