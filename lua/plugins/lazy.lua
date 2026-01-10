--[[
    plugins/lazy.lua
    description: install and setting lazy.nvim
--]]

local lazypath = vim.fs.joinpath(vim.fn.stdpath "data", "lazy/lazy.nvim")

if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--brance=stable",
        lazypath,
    })
end

-- set the priority of lazy.nvim
vim.opt.rtp:prepend(lazypath)

-- the setting of lazy.nvim
XzwNvim.lazy = {

}

