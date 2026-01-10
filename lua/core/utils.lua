--[[
    core/utils.lua
    description: utils in core neovim setting
--]]
local utils = {}

utils.group_map = function(group, opt)
    if not opt then
        opt = {}
    end

    for desc, keymap in pairs(group) do
        desc = string.gsub(desc, "_", " ")

        -- 合并 opt 与对应选项
        local default_option = vim.tbl_extend("force", { desc = desc, nowait = true, silent = true }, opt)

        -- keymap 的值填入到指定位置
        local map = vim.tbl_deep_extend("force", { nil, nil , nil, default_option }, keymap)
        vim.keymap.set(map[1], map[2], map[3], map[4])
    end
end

return utils
