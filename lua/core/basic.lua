local g = vim.g
local opt = vim.opt

--[[
    core/basic.lua
    description: basic setting of nvim
--]]

vim.cmd "language en_US.UTF-8"
vim.cmd "syntax off"

g.encoding = "UTF-8"
opt.fileencoding = "utf-8"

-- get the size of nvim window
local win_height = vim.fn.winheight(0)

-- control the position of cursor
opt.scrolloff = math.floor((win_height - 1) / 2)
opt.sidescrolloff = math.floor((win_height - 1) / 2)

opt.number = true
opt.relativenumber = true

opt.cursorline = true

opt.signcolumn = "yes"

-- set the line length limit
opt.colorcolumn = "80"

-- set the tab to 4 space
opt.tabstop = 4
opt.shiftwidth = 0
opt.expandtab = true

opt.shiftround = true

-- search setting
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = false

-- cmd line setting
opt.cmdheight    = 1
opt.cmdwinheight = 1

opt.autoread = true

opt.whichwrap = "<,>,[,]"

opt.hidden = true

-- mouse setting
opt.mouse = "a"
opt.mousemodel = "extend"

-- backup file setting
opt.backup      = false
opt.writebackup = false
opt.swapfile    = false

-- split setting
opt.splitbelow = true
opt.splitright = true

opt.timeoutlen = 500

-- color support
opt.termguicolors = true

opt.pumheight = 16

-- tab 
opt.showtabline = 2
opt.tabline     = "%!''"

opt.showmode = false

opt.nrformats = "bin,hex,alpha"

-- fold setting
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = false

opt.laststatus = 3

vim.o.clipboard = "unnamedplus"

-- termial setting
-- :termial
vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
        vim.wo.number = false
        vim.wo.relativenumber = false
    end
})

-- shadafile setting
opt.shadafile = "NONE"
vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdwinEnter"}, {
    once = true,
    callback = function()
        local shada = vim.fs.joinpath(vim.fn.stdpath "state", "shada/main.shada")
        vim.o.shadafile = shada
        vim.cmd("rshada!" .. shada)
    end
})

-- cmd win
vim.api.nvim_create_autocmd("CmdwinEnter", {
    callback = function()
        vim.cmd "startinsert"
        vim.wo.number = false
        vim.wo.relativenumber = false
    end
})

-- new window
vim.api.nvim_create_autocmd("WinNew", {
    callback = function()
        vim.wo.wrap = false
    end
})

-- autosave
vim.api.nvim_create_autocmd("BufLeave", {
    callback = function()
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
        if buftype == "" then
            vim.cmd("silent! update")
        end
    end
})

vim.wo.wrap = false
