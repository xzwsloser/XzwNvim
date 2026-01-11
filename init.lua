XzwNvim = {}

require("core.init")
require("plugins.init")



-- keymap setting
require("core.utils").group_map(XzwNvim.keymap)

-- lazy.nvim load
require("lazy").setup(vim.tbl_values(XzwNvim.plugins), XzwNvim.lazy)

-- set the begin event
vim.api.nvim_create_autocmd("User", {
    once = true,
    pattern = "VeryLazy",
    callback = function()
        -- scan plugin dir
        local rtp_plugin_path = vim.fs.joinpath(vim.opt.packpath:get()[1], "plugin")
        local dir = vim.uv.fs_scandir(rtp_plugin_path)
        if dir ~= nil then
            while true do
                local plugin, entry_type = vim.uv.fs_scandir_next(dir)
                if plugin == nil or entry_type == "directory" then
                    break
                else
                    vim.cmd(string.format("source %s/%s", rtp_plugin_path, plugin))
                end
            end
        end

        if not XzwNvim.colorscheme then
            XzwNvim.colorscheme = "tokyonight"
            local colorscheme_cache = vim.fs.joinpath(vim.fn.stdpath "data", "colorscheme")
            if vim.uv.fs_stat(colorscheme_cache) then
                local colorscheme_cache_file = io.open(colorscheme_cache, "r")
                ---@diagnostic disable: need-check-nil
                local colorscheme = colorscheme_cache_file:read "*a"
                colorscheme_cache_file:close()
                XzwNvim.colorscheme = colorscheme
            end
        end

        require("plugins.utils").colorscheme(XzwNvim.colorscheme)
    end,
})


