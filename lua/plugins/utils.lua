--[[
    plugins/utils.lua
    description: utils used in plugins setting
--]]

local utils = {}

utils.colorscheme = function(colorscheme_name)
    XzwNvim.colorscheme = colorscheme_name

    local colorscheme = XzwNvim.colorschemes[colorscheme_name]
    if not colorscheme then
        vim.notify(colorscheme_name .. " is not a valid color scheme!", vim.log.levels.ERROR)
        return
    end

    -- Load colorscheme
    if type(colorscheme.setup) == "table" then
        require(colorscheme.name).setup(colorscheme.setup)
    elseif type(colorscheme.setup) == "function" then
        colorscheme.setup()
    end

    require("lazy.core.loader").colorscheme(colorscheme.name)
    vim.cmd("colorscheme " .. colorscheme.name)
    vim.o.background = colorscheme.background

    vim.api.nvim_set_hl(0, "Visual", { reverse = true })

    -- emit event (ColorScheme Loaded)
    vim.api.nvim_exec_autocmds("User", { pattern = "XzwNvimAfter colorscheme" })

    -- TODO: set transparent style

end

-- Quickly look through configuration files using telescope
utils.view_configuration = function()
    local status, _ = pcall(require, "telescope")
    if not status then
        return
    end

    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"
    local previewers = require "telescope.previewers.buffer_previewer"
    local from_entry = require "telescope.from_entry"

    local function picker(opts)
        opts = opts or {}

        local config_root = vim.fn.stdpath "config"
        local files = require("plenary.scandir").scan_dir(config_root, { hidden = true })
        local sep = require("plenary.path").path.sep
        local picker_sep = "/" -- sep that is displayed in the picker
        local results = {}

        local make_entry = require("telescope.make_entry").gen_from_file

        for _, item in pairs(files) do
            item = string.gsub(item, config_root, "")
            item = string.gsub(item, sep, picker_sep)
            item = string.sub(item, 2)
            if not (string.find(item, "bin/") or string.find(item, ".git/") or string.find(item, "screenshots/")) then
                results[#results + 1] = item
            end
        end

        pickers
            .new(opts, {
                prompt_title = "Configuration Files",
                finder = finders.new_table {
                    entry_maker = make_entry(opts),
                    results = results,
                },
                previewer = (function(_opts)
                    _opts = _opts or {}
                    return previewers.new_buffer_previewer {
                        title = "Configuration",
                        get_buffer_by_name = function(_, entry)
                            return from_entry.path(entry, false)
                        end,
                        define_preview = function(self, entry)
                            local p = vim.fs.joinpath(config_root, entry.filename)
                            if p == nil or p == "" then
                                return
                            end
                            conf.buffer_previewer_maker(p, self.state.bufnr, {
                                bufname = self.state.bufname,
                                winid = self.state.winid,
                                preview = _opts.preview,
                                file_encoding = _opts.file_encoding,
                            })
                        end,
                    }
                end)(opts),
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr, _)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)

                        local selected_entry = action_state.get_selected_entry()
                        if selected_entry ~= nil then
                            local selection = selected_entry[1]
                            selection = string.gsub(selection, picker_sep, sep)
                            local full_path = vim.fs.joinpath(config_root, selection)

                            vim.cmd("edit " .. full_path)
                        end
                    end)
                    return true
                end,
            })
            :find()
    end

    picker()
end

vim.api.nvim_create_user_command("XzwNvimColorscheme", function(args)
    local colorscheme = args.args
    utils.colorscheme(colorscheme)

    local colorscheme_cache = vim.fs.joinpath(vim.fn.stdpath "data", "colorscheme")
    local f = io.open(colorscheme_cache, "w")
    f:write(colorscheme)
    f:close()
end, {
    nargs = 1,
    complete = function(_,_)
        return vim.tbl_keys(XzwNvim.colorschemes)
    end,
})

return utils
