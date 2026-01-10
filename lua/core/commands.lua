--[[
    core/commandas
    description: user define command 
--]]

-- @description: setting the win and buf
local function config_window(win, buf)
    -- close the window with q
    vim.keymap.set("n", "q", "<C-w>c", { buffer = buf })

    vim.api.nvim_set_option_value("number", false, { win = win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = win })
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
    vim.api.nvim_set_option_value("cursorline", false, { win = win })
    vim.api.nvim_set_option_value("colorcolumn", "", { win = win })

    -- replace the show char
    vim.api.nvim_set_option_value("fillchars", "eob: ", { win = win })
end

-- @description: command XzwNvimAbout 
vim.api.nvim_create_user_command("XzwNvimAbout", 
function()
    local buf = vim.api.nvim_create_buf(false, true)

    local win_w = vim.fn.winwidth(0)
    local win_h = vim.fn.winheight(0)

    local width = 80
    local height = math.floor(win_h * 0.3)

    local left = math.floor((win_w - width) / 2)
    local top  = math.floor((win_h - height) / 2)

    -- setting text
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "",
        "Neovim Setting For MySelf",
        "",
        "Author: ZhiWei Xiao",
        "",
        "url: https://github.com/xzwsloser",
        "",
        string.format("Copyright © 2026-%s ZhiWei Xiao", os.date "%Y"),
    })

    -- create the window
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "win",
        width    = width,
        height   = height,
        row      = top,
        col      = left,
        border   = "rounded",
        title    = "About XzwNvim",
        title_pos  = "center",
        footer     = "Press q to close window",
        footer_pos = "center",
    })

    config_window(win, buf)
end
, { nargs = 0 })
