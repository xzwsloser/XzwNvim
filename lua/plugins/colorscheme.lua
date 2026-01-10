--[[
    plugins/colorscheme.lua
    description: setting colorscheme of neovim
--]]

XzwNvim.colorschemes = {
    tokyonight = {
        name = "tokyonight",
        -- 暗色主题
        background = "dark",
        setup = {
            -- moon 样式
            style = "moon",

            -- 注释 -> 斜体
            -- 关键词 -> 非斜体
            styles = {
                comments = { italic = true },
                keywords = { italic = false },
            }
        }
    }
}

