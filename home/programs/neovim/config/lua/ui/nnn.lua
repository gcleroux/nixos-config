local nnn_status_ok, nnn = pcall(require, "nnn")
if not nnn_status_ok then
    vim.notify("Plugin nnn is missing")
    return
end

local function copy_to_clipboard(lines)
    local joined_lines = table.concat(lines, "\n")
    vim.fn.setreg("+", joined_lines)
end

local function cd_selected_dir(lines)
    local dir = lines[#lines]
    if vim.fn.filereadable(dir) == 1 then
        dir = vim.fn.fnamemodify(dir, ":h")
    end
    vim.api.nvim_command("cd " .. vim.fn.shellescape(dir))
end

nnn.setup({
    command = "nnn -o",
    set_default_mappings = 0,
    replace_netrw = "1",
    action = {
        ["<C-t>"] = "tab split",
        ["<C-h>"] = "split",
        ["<C-v>"] = "vsplit",
        ["<C-y>"] = copy_to_clipboard,
        ["<C-c>"] = cd_selected_dir,
    },
})
