local toggleterm_status_ok, toggleterm = pcall(require, "toggleterm")
if not toggleterm_status_ok then
    vim.notify("Plugin toggleterm is missing")
    return
end

local terminal = require("toggleterm.terminal").Terminal

toggleterm.setup({
    open_mapping = [[<c-t>]],
})

local lazygit = terminal:new({
    cmd = "lazygit",
    dir = "git_dir",
    direction = "float",
    float_opts = {
        border = "double",
        width = function()
            return math.floor(vim.o.columns * 0.9)
        end,
        height = function()
            return math.floor(vim.o.lines * 0.9)
        end,
    },
    -- function to run on opening the terminal
    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
    -- function to run on closing the terminal
    on_close = function(term)
        vim.cmd("startinsert!")
    end,
})

local bottom = terminal:new({
    cmd = "btm",
    direction = "float",
    float_opts = {
        border = "double",
        width = function()
            return math.floor(vim.o.columns * 0.9)
        end,
        height = function()
            return math.floor(vim.o.lines * 0.9)
        end,
    },
    -- function to run on opening the terminal
    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
    -- function to run on closing the terminal
    on_close = function(term)
        vim.cmd("startinsert!")
    end,
})

function _lazygit_toggle()
    lazygit:toggle()
end

function _bottom_toggle()
    bottom:toggle()
end

vim.api.nvim_set_keymap("n", "<leader>gg", "<cmd>lua _lazygit_toggle()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>mm", "<cmd>lua _bottom_toggle()<CR>", { noremap = true, silent = true })
