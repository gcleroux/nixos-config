local go_status_ok, go = pcall(require, "go")
if not go_status_ok then
    vim.notify("Plugin go is missing")
    return
end

go.setup({
    disable_defaults = false, -- true|false when true set false to all boolean settings and replace all table
    -- settings with {}
    go = "go", -- go command, can be go[default] or go1.18beta1
    goimport = "gopls", -- goimport command, can be gopls[default] or either goimport or golines if need to split long lines
    fillstruct = "fillstruct", -- default, can also use fillstruct
    gofmt = "gofumpt", --gofmt cmd,
    max_line_len = 120, -- max line length in golines format, Target maximum line length for golines
    tag_transform = false, -- can be transform option("snakecase", "camelcase", etc) check gomodifytags for details and more options
    tag_options = "json=omitempty", -- sets options sent to gomodifytags, i.e., json=omitempty
    gotests_template = "", -- sets gotests -template parameter (check gotests for details)
    gotests_template_dir = "", -- sets gotests -template_dir parameter (check gotests for details)
    comment_placeholder = "", -- comment_placeholder your cool placeholder e.g. 󰟓       
    icons = { breakpoint = "", currentpos = "󱦰" }, -- setup to `false` to disable icons setup
    verbose = false, -- output loginf in messages
    lsp_cfg = false, -- true: use non-default gopls setup specified in go/lsp.lua
    -- false: do nothing
    -- if lsp_cfg is a table, merge table with with non-default gopls setup in go/lsp.lua, e.g.
    --   lsp_cfg = {settings={gopls={matcher='CaseInsensitive', ['local'] = 'your_local_module_path', gofumpt = true }}}
    lsp_gofumpt = true, -- true: set default gofmt in gopls format to gofumpt
    lsp_on_attach = nil, -- nil: use on_attach function defined in go/lsp.lua,
    --      when lsp_cfg is true
    -- if lsp_on_attach is a function: use this function as on_attach function for gopls
    lsp_keymaps = false, -- set to false to disable gopls/lsp keymap
    lsp_codelens = false, -- set to false to disable codelens, true by default, you can use a function
    -- function(bufnr)
    --    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>F", "<cmd>lua vim.lsp.buf.formatting()<CR>", {noremap=true, silent=true})
    -- end
    -- to setup a table of codelens
    diagnostic = false,
    lsp_document_formatting = false,
    -- set to true: use gopls to format
    -- false if you want to use other formatter tool(e.g. efm, nulls)
    gopls_cmd = nil,       -- if you need to specify gopls path and cmd, e.g {"/home/user/lsp/gopls", "-logfile","/var/log/gopls.log" }
    gopls_remote_auto = true, -- add -remote=auto to gopls
    gocoverage_sign = "█",
    sign_priority = 5,     -- change to a higher number to override other signs
    dap_debug = true,      -- set to false to disable dap
    dap_debug_keymap = false, -- true: use keymap for debugger defined in go/dap.lua
    -- false: do not use keymap in go/dap.lua.  you must define your own.
    -- Windows: Use Visual Studio keymap
    dap_debug_gui = true,   -- bool|table put your dap-ui setup here set to false to disable
    dap_debug_vt = true,    -- bool|table put your dap-virtual-text setup here set to false to disable

    dap_port = 38697,       -- can be set to a number, if set to -1 go.nvim will pick up a random port
    dap_timeout = 15,       --  see dap option initialize_timeout_sec = 15,
    dap_retries = 20,       -- see dap option max_retries
    build_tags = "",        -- set default build tags
    textobjects = false,    -- enable default text jobects through treesittter-text-objects
    test_runner = "gotestsum", -- one of {`go`, `richgo`, `dlv`, `ginkgo`, `gotestsum`}
    verbose_tests = true,   -- set to add verbose flag to tests deprecated, see '-v' option
    run_in_floaterm = false, -- set to true to run in a float window. :GoTermClose closes the floatterm
    -- float term recommend if you use richgo/ginkgo with terminal color

    trouble = false,       -- true: use trouble to open quickfix
    test_efm = false,      -- errorfomat for quickfix, default mix mode, set to true will be efm only
    luasnip = false,       -- enable included luasnip snippets. you can also disable while add lua/snips folder to luasnip load
    iferr_vertical_shift = 4, -- defines where the cursor will end up vertically from the begining of if err statement
})
