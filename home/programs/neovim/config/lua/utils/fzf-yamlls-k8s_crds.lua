local M = {}

local fzf = require("fzf-lua")
local curl = require("plenary.curl")

-- Function to get the latest commit SHA for the main branch
local function get_latest_sha()
    local response = curl.get("https://api.github.com/repos/datreeio/CRDs-catalog/branches/main", {
        timeout = 1000,
    })
    if response.status ~= 200 then
        vim.notify("Failed to fetch SHA (HTTP " .. response.status .. ")", vim.log.levels.ERROR)
        return {}
    end
    local data = vim.fn.json_decode(response.body)
    return data and data.commit and data.commit.sha or nil
end

-- Function to fetch schema list
local function get_crd_schema_list()
    local latest_sha = get_latest_sha()
    if not latest_sha then
        return {}
    end

    local cache_file = vim.fn.stdpath("cache") .. "/crd_schemas." .. latest_sha .. ".json"
    local json_text

    -- If the cache file exists, read from it.
    if vim.uv.fs_stat(cache_file) then
        local lines = vim.fn.readfile(cache_file)
        json_text = table.concat(lines, "\n")
    else
        -- Delete previous cached files
        local files = vim.fn.glob(vim.fn.stdpath("cache") .. "/crd_schemas.*", false, true)
        for _, file in ipairs(files) do
            vim.fn.delete(file)
        end

        -- GitHub API call to get all files in the repository tree (recursive)
        local response = curl.get("https://api.github.com/repos/datreeio/CRDs-catalog/git/trees/main?recursive=1", {
            headers = { ["Accept"] = "application/vnd.github.v3+json" },
            timeout = 2000,
        })
        if response.status ~= 200 then
            vim.notify("Failed to fetch CRD schemas list (HTTP " .. response.status .. ")", vim.log.levels.ERROR)
            return {}
        end
        -- Cache the response
        vim.fn.writefile(vim.split(response.body, "\n"), cache_file)
        json_text = response.body
    end

    local data = vim.fn.json_decode(json_text)
    local schemas = {}
    if data and data.tree then
        for _, item in ipairs(data.tree) do
            if item.path and item.path:match("%.json$") then
                table.insert(schemas, item.path)
            end
        end
    end
    return schemas
end

-- Main function to open fzf and insert modeline
function M.insert_crd_schema_modeline()
    local schemas = get_crd_schema_list()
    if #schemas == 0 then
        vim.notify("No schemas available to select", vim.log.levels.WARN)
        return
    end
    -- Use fzf-lua to let user pick a schema
    fzf.fzf_exec(schemas, {
        prompt = "Select CRD Schema> ",
        actions = {
            ["default"] = function(selected)
                if not selected or not selected[1] then
                    return -- user canceled or nothing selected
                end
                -- Construct the YAML LS modeline with the chosen schema URL
                local schema_path = selected[1]
                local schema_url = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/" .. schema_path
                local modeline = "# yaml-language-server: $schema=" .. schema_url

                local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
                -- Insert at top of current buffer
                vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { modeline })
            end,
        },
    })
end

vim.api.nvim_create_user_command("InsertCRDSchema", M.insert_crd_schema_modeline, {})

return M
