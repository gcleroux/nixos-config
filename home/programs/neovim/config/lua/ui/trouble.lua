local trouble_status_ok, trouble = pcall(require, "trouble")
if not trouble_status_ok then
    vim.notify("Plugin trouble is missing")
    return
end

trouble.setup({})
