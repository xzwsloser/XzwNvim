--[[
    core/keymap.lua
    description: define the keymap of nvim
--]]

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- @description: save file function
local function save_file()
	local buffer_is_modified = vim.api.nvim_get_option_value("modified", { buf = 0 })
	if buffer_is_modified then
		vim.cmd("write")
	else
		print("Buffer not modified. No writing is done.")
	end

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

-- @description: undo the operation
local function undo()
	local mode = vim.api.nvim_get_mode().mode

	if mode == "n" or mode == "i" or mode == "v" then
		vim.cmd("undo")
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
	end
end

-- @description: copy content to copyq
local function text_to_copyq()
    local text = vim.fn.getreg('"')
    if not text or text == "" then
        vim.notify("无名寄存器为空，无内容可发送到 CopyQ", vim.log.levels.WARN)
        return
    end


    local cmd = string.format('copyq add %q', text)
    local result = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
        vim.notify("发送内容到 CopyQ 失败：" .. result, vim.log.levels.ERROR)
    else
        vim.notify("内容已成功发送到 CopyQ", vim.log.levels.INFO)
    end
end

-- @description: from copyq to neovim
local function copyq_to_neovim()
	local text = vim.fn.system("copyq read 0 --text")
	text = text:gsub("\n$", "")
	vim.api.nvim_put({ text }, "c", false, true)
end

-- @description: open the terminal for linux
local terminal_command = "<Cmd>split | terminal<CR>"

XzwNvim.keymap = {
	move_to_backhole_register = { { "n", "v" }, "\\", '"_' },

	-- operation in command mode
	clear_cmd_line = { { "n", "i", "v", "t" }, "<C-g>", "<Cmd>mode<CR>" },
	cmd_forward = { "c", "<C-f>", "<Right>", { silent = false } },
	cmd_backward = { "c", "<C-b>", "<Left>", { silent = false } },
	cmd_home = { "c", "<C-a>", "<Home>", { silent = false } },
	cmd_end = { "c", "<C-e>", "<End>", { silent = false } },
	cmd_word_forward = { "c", "<A-f>", "<S-Right>", { silent = false } },
	cmd_word_backward = { "c", "<A-b>", "<S-Left>", { silent = false } },

	-- mouse setting
	disable_ctrl_left_mouse = { "n", "<C-LeftMouse>", "" },
	disable_right_mouse = { { "n", "i", "v", "t" }, "<RightMouse>", "<LeftMouse>" },

	-- Lazy Profile
	lazy_profile = { "n", "<leader>lz", "<Cmd>Lazy<CR>" },

	open_terminal = { "n", "<C-t>", terminal_command },
	save_file = { { "n", "i", "v" }, "<C-s>", save_file },
	undo = { { "n", "i", "v", "t", "c" }, "<C-z>", undo },

	-- select the current line
	-- visual_line = { "n", "v", "0v$" },

	-- custom
	back_to_normal_mode = { "i", "jk", "<Esc>" },

	-- copyq
	text_to_copyq = { "n", "<leader>yy", text_to_copyq },
    copyq_paste = { "n", "<leader>p", copyq_to_neovim },
}

