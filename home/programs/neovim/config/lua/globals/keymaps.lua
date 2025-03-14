-- Functional wrapper for mapping custom keybindings
local function keymap(mode, lhs, rhs)
    local options = { noremap = true, silent = true }
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- TODO: Refactor this file into a directory with 1 file per extension keymaps

------------------------------
--    General keybindings   --
------------------------------

-- Close the current buffer
vim.keymap.set("n", "<leader>q", function()
    require("bufdelete").bufdelete()
end)

-- Close every buffer forcibly
vim.keymap.set("n", "<leader>Q", function()
    vim.cmd("bufdo lua require('bufdelete').bufwipeout(0, true)")
end)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>")
keymap("n", "<S-h>", ":bprevious<CR>")

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>")
keymap("n", "<C-Down>", ":resize -2<CR>")
keymap("n", "<C-Left>", ":vertical resize -2<CR>")
keymap("n", "<C-Right>", ":vertical resize +2<CR>")

-- Visual --
-- Stay in indent mode
keymap("v", "<S-Tab>", "<gv")
keymap("v", "<Tab>", ">gv")

-- Move text up and down
keymap("v", "p", '"_dP')
keymap("v", "<A-j>", ":m .+1<CR>==")
keymap("v", "<A-k>", ":m .-2<CR>==")

-- Visual Block --
-- Move text up and down
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv")
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv")

-- Generate docstring
keymap("n", "<leader>doc", ":Neogen<CR>")

-- Debugger keymaps
keymap("n", "<F5>", "<cmd>lua require'dap'.continue()<CR>")
keymap("n", "<F10>", "<cmd>lua require'dap'.step_over()<CR>")
keymap("n", "<F11>", "<cmd>lua require'dap'.step_into()<CR>")
keymap("n", "<F12>", "<cmd>lua require'dap'.step_out()<CR>")
keymap("n", "<leader>b", "<cmd>lua require'dap'.toggle_breakpoint()<CR>")
keymap("n", "<leader>B", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
keymap("n", "<leader>lp", ",<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
keymap("n", "<leader>dbg", "<cmd>lua require'dap'.repl.open()<CR>")
keymap("n", "<leader>rl", "<cmd>lua require'dap'.run_last()<CR>")

-- Gitsigns
keymap("n", "<leader>hr", ":Gitsigns reset_hunk<CR>")
keymap("n", "<leader>hp", ":Gitsigns preview_hunk<CR>")
keymap("n", "<leader>hn", ":Gitsigns next_hunk<CR>")
keymap("n", "<leader>hb", ":Gitsigns prev_hunk<CR>")

-- Pressing backspace in normal mode returns to previous opened file
keymap("n", "<leader>L", ":noh<CR>")
