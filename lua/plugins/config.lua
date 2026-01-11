--[[
    plugins/config.lua
    description: the configuration of plugins
--]]

local config = {}
local symbols = XzwNvim.symbols
local config_root = vim.fn.stdpath "config"

-- neovim plugins load event
vim.api.nvim_create_autocmd("User", {
    pattern = "XzwNvimAfter colorscheme",
    callback = function()
        local function should_trigger()
            return vim.bo.filetype ~= "dashboard" and vim.api.nvim_buf_get_name(0) ~= ""
        end

        local function trigger()
            vim.api.nvim_exec_autocmds("User", { pattern = "XzwNvimLoad" } )
        end

        if should_trigger() then
            trigger()
            return
        end

        local nvim_load
        nvim_load = vim.api.nvim_create_autocmd("BufEnter", {
            callback = function()
                if should_trigger() then
                    trigger()
                    vim.api.nvim_del_autocmd(nvim_load)
                end
            end,
        })
    end,
})

-- bufferline(缓冲区管理)
config.bufferline = {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "User XzwNvimLoad",
    opts = {
        options = {
            close_command = ":BufferLineClose %d",
            right_mouse_command = ":BufferLineClose %d",
            separator_style = "thin",
            offsets = {
                {
                    filetype = "NvimTree",
                    text = "File Explorer",
                    highlight = "Directory",
                    text_align = "left",
                },
            },
            diagnostics = "nvim_lsp",
            -- 集成 lsp 报错信息
            diagnostics_indicator = function(_, _, diagnostics_dict, _)
                local s = " "
                for e, n in pairs(diagnostics_dict) do
                    local sym = e == "error" and symbols.Error or (e == "warning" and symbols.Warn or symbols.Info)
                    s = s .. n .. sym
                end
                return s
            end,
        },
    },
    config = function(_, opts)
        vim.api.nvim_create_user_command("BufferLineClose", function(buffer_line_opts)
            local bufnr = 1 * buffer_line_opts.args
            local buf_is_modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })

            local bdelete_arg
            if bufnr == 0 then
                bdelete_arg = ""
            else
                bdelete_arg = " " .. bufnr
            end
            local command = "bdelete!" .. bdelete_arg
            if buf_is_modified then
                local option = vim.fn.confirm("File is not saved. Close anyway?", "&Yes\n&No", 2)
                if option == 1 then
                    vim.cmd(command)
                end
            else
                vim.cmd(command)
            end
        end, { nargs = 1 })

        require("bufferline").setup(opts)

        require("nvim-web-devicons").setup({})
    end,
    -- 快捷键定义
    keys = {
        { "<leader>bc", "<Cmd>BufferLinePickClose<CR>", desc = "pick close", silent = true },
        { "<leader>bd", "<Cmd>BufferLineClose 0<CR>", desc = "close current buffer", silent = true },
        { "<leader>bh", "<Cmd>BufferLineCyclePrev<CR>", desc = "prev buffer", silent = true },
        { "<leader>bl", "<Cmd>BufferLineCycleNext<CR>", desc = "next buffer", silent = true },
        { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "close others", silent = true },
        { "<leader>bp", "<Cmd>BufferLinePick<CR>", desc = "pick buffer", silent = true },
    },
}

-- colorizer(显示颜色)
config.colorizer = {
    "NvChad/nvim-colorizer.lua",
    main = "colorizer",
    event = "User XzwNvimLoad",
    opts = {
        filetypes = {
            "*",
            css = {
                names = true,
            },
        },
        user_default_options = {
            css = true,
            css_fn = true,
            names = false,
            always_update = true,
        },
    },
    config = function(_, opts)
        require("colorizer").setup(opts)
        vim.cmd "ColorizerToggle"
    end,
}

local function align_dashboard_icon()
    local rows = vim.api.nvim_win_get_height(0)
    local n = math.floor(rows / 4) -- 计算需要的空行数量

    local prefix_lines = {}
    for _ = 1, n do
        table.insert(prefix_lines, "")
    end
    
    local icon_lines = {
        "██╗  ██╗███████╗██╗    ██╗███╗   ██╗██╗   ██╗██╗███╗   ███╗",
        "╚██╗██╔╝╚══███╔╝██║    ██║████╗  ██║██║   ██║██║████╗ ████║",
        " ╚███╔╝   ███╔╝ ██║ █╗ ██║██╔██╗ ██║██║   ██║██║██╔████╔██║",
        " ██╔██╗  ███╔╝  ██║███╗██║██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "██╔╝ ██╗███████╗╚███╔███╔╝██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝"
    }
    
    local result = vim.list_extend(prefix_lines, icon_lines)

    return result
end

-- dashboard(导航面板)
config.dashboard = {
    "nvimdev/dashboard-nvim",
    event = "User XzwNvimAfter colorscheme",
    opts = {
        theme = "doom",
        config = {
            -- https://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=icenvim
            header = align_dashboard_icon(),
            center = {
                {
                    icon = " ",
                    desc = "New File",
                    action = "enew"
                },

                {
                    icon = "  ",
                    desc = "Lazy Profile",
                    action = "Lazy",
                },

                {
                    icon = "  ",
                    desc = "Edit preferences   ",
                    action = string.format("edit %s/init.lua", config_root),
                },

               {
                    icon = "  ",
                    desc = "Mason",
                    action = "Mason",
                },
                
                {
                    icon = "  ",
                    desc = "About XzwNvim",
                    action = "XzwNvimAbout",
                },

            },
            footer = { "🧊 Cheer up and keep striving for your goal 😀😀😀" },
        },
    },
    config = function(_, opts)
        require("dashboard").setup(opts)

        if vim.api.nvim_buf_get_name(0) == "" then
            vim.cmd "Dashboard"
        end

        -- Use the highlight command to replace instead of overriding the original highlight group
        -- Much more convenient than using vim.api.nvim_set_hl()
        vim.cmd "highlight DashboardFooter cterm=NONE gui=NONE"
    end,
}

-- LSP notify
config.fidget = {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    opts = {
        notification = {
            override_vim_notify = true,
            window = {
                winblend = 0,
                x_padding = 2,
                align = "top",
            },
        },
        integration = {
            ["nvim-tree"] = {
                enable = false,
            },
        },
    },
}

-- grug-far(字符串查找替换)
config["grug-far"] = {
    "MagicDuck/grug-far.nvim",
    opts = {
        disableBufferLineNumbers = true,
        startInInsertMode = true,
        windowCreationCommand = "tabnew %",
    },
    keys = {
        { "<leader>ug", "<Cmd>GrugFar<CR>", desc = "find and replace", silent = true },
    },
}

-- hop(支持快速跳转)
config.hop = {
    "smoka7/hop.nvim",
    main = "hop",
    opts = {
        -- This is actually equal to:
        --   require("hop.hint").HintPosition.END
        hint_position = 3,
        keys = "fjghdksltyrueiwoqpvbcnxmza",
    },
    keys = {
        { "<leader>hp", "<Cmd>HopWord<CR>", desc = "hop word", silent = true },
    },
}

-- lualine(状态栏)
config.lualine = {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "User XzwNvimLoad",
    main = "lualine",
    opts = {
        options = {
            theme = "auto",
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
            disabled_filetypes = { "undotree", "diff" },
        },
        extensions = { "nvim-tree" },
        sections = {
            lualine_b = { "branch", "diff" },
            lualine_c = {
                "filename",
            },
            lualine_x = {
                "filesize",
                {
                    "fileformat",
                    symbols = { unix = symbols.Unix, dos = symbols.Dos, mac = symbols.Mac },
                },
                "encoding",
                "filetype",
            },
        },
    },
}

-- markdown preview(Markdown预览)
config["markdown-preview"] = {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    config = function()
        vim.g.mkdp_filetypes = { "markdown" }
        vim.g.mkdp_auto_close = 0
    end,

    build = "cd app yarn npm install",

    keys = {
        {
            "<leader>mp",
            "<Cmd>MarkdownPreviewToggle<CR>",
            desc = "markdown preview",
            ft = "markdown",
            silent = true,
        },
    },
}

-- neogit(git 可视化)
config.neogit = {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    main = "neogit",
    opts = {
        disable_hint = true,
        status = {
            recent_commit_count = 30,
        },
        commit_editor = {
            kind = "auto",
            show_staged_diff = false,
        },
    },
    keys = {
        { "<leader>gt", "<Cmd>Neogit<CR>", desc = "neogit", silent = true },
    },
    config = function(_, opts)
        require("neogit").setup(opts)
    end,
}

-- ui lib for neovim
config.nui = {
    "MunifTanjim/nui.nvim",
    lazy = true,
}

-- auto pair(括号自动匹配)
config["nvim-autopairs"] = {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    main = "nvim-autopairs",
    opts = {},
}

-- 滚动条显示
config["nvim-scrollview"] = {
    "dstein64/nvim-scrollview",
    event = "User XzwNvimLoad",
    main = "scrollview",
    opts = {
        excluded_filetypes = { "nvimtree" },
        current_only = true,
        winblend = 75,
        base = "right",
        column = 1,
    },
}

-- neotree(文件树显示)
config["nvim-tree"] = {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        -- 依附在当前缓冲区中
        on_attach = function(bufnr)
            local api = require "nvim-tree.api"
            local opt = { buffer = bufnr, silent = true }

            api.config.mappings.default_on_attach(bufnr)

            require("core.utils").group_map({
                edit = {
                    "n",
                    "<CR>",
                    function()
                        local node = api.tree.get_node_under_cursor()
                        if node.name ~= ".." and node.fs_stat.type == "file" then
                            -- Taken partially from:
                            -- https://support.microsoft.com/en-us/windows/common-file-name-extensions-in-windows-da4a4430-8e76-89c5-59f7-1cdbbc75cb01
                            --
                            -- Not all are included for speed's sake
                            -- stylua: ignore start
                            local extensions_opened_externally = {
                                "avi", "bmp", "doc", "docx", "exe", "flv", "gif", "jpg", "jpeg", "m4a", "mov", "mp3",
                                "mp4", "mpeg", "mpg", "pdf", "png", "ppt", "pptx", "psd", "pub", "rar", "rtf", "tif",
                                "tiff", "wav", "xls", "xlsx", "zip",
                            }
                            -- stylua: ignore end
                            -- if table.find(extensions_opened_externally, node.extension) then
                            --     api.node.run.system()
                            --     return
                            -- end

                            local function table_find(t, val)
                                for _, v in ipairs(t) do
                                    if v == val then
                                        return true
                                    end
                                end
                                return false
                            end

                            if table_find(extensions_opened_externally, node.extension) then
                                api.node.run.system()
                                return
                            end
                        end

                        api.node.open.edit()
                    end,
                },
                -- 相关快捷键
                -- 分屏相关
                vertical_split = { "n", "V", api.node.open.vertical },
                horizontal_split = { "n", "H", api.node.open.horizontal },

                toggle_hidden_file = { "n", ".", api.tree.toggle_hidden_filter },
                reload = { "n", "<F5>", api.tree.reload },
                create = { "n", "a", api.fs.create },
                remove = { "n", "d", api.fs.remove },
                rename = { "n", "r", api.fs.rename },
                cut = { "n", "x", api.fs.cut },
                copy = { "n", "y", api.fs.copy.node },
                paste = { "n", "p", api.fs.paste },
                system_run = { "n", "s", api.node.run.system },
                show_info = { "n", "i", api.node.show_info_popup },
            }, opt)
        end,
        git = {
            enable = false,
        },
        update_focused_file = {
            enable = true,
        },
        filters = {
            dotfiles = false,
            custom = { "node_modules", "^.git$" },
            exclude = { ".gitignore" },
        },
        respect_buf_cwd = true,
        view = {
            width = 30,
            side = "left",
            number = false,
            relativenumber = false,
            signcolumn = "yes",
        },
        actions = {
            open_file = {
                resize_window = true,
                quit_on_open = true,
            },
        },
    },
    keys = {
        { "<leader>uf", "<Cmd>NvimTreeToggle<CR>", desc = "toggle nvim tree", silent = true },
    },
}

-- indent-blankline 代码缩进显示
config["indent-blankline"] = {
    "lukas-reineke/indent-blankline.nvim",
    event = "User XzwNvimAfter nvim-treesitter",
    main = "ibl",
    opts = {
        exclude = {
            filetypes = { "dashboard", "terminal", "help", "log", "markdown", "TelescopePrompt" },
        },
        indent = {
            highlight = {
                "IblIndent",
                "RainbowDelimiterRed",
                "RainbowDelimiterYellow",
                "RainbowDelimiterBlue",
                "RainbowDelimiterOrange",
                "RainbowDelimiterGreen",
                "RainbowDelimiterViolet",
                "RainbowDelimiterCyan",
            },
        },
    },
}

-- nvim-treesitter(高亮显示 AST 解析)
config["nvim-treesitter"] = {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = { "hiphish/rainbow-delimiters.nvim" },
    event = "User XzwNvimAfter colorscheme",
    branch = "main",
    opts = {
        -- Preserved for compatibility concerns
        -- stylua: ignore start
        ensure_installed = {
            "c", "cpp", "python", "lua", "bash", "go" 
        },
        -- stylua: ignore end
    },
    config = function(_, opts)
        local nvim_treesitter = require "nvim-treesitter"
        nvim_treesitter.setup()

        local pattern = {}
        for _, parser in ipairs(opts.ensure_installed) do
            local has_parser, _ = pcall(vim.treesitter.language.inspect, parser)

            if not has_parser then
                -- Needs restart to take effect
                nvim_treesitter.install(parser)
            else
                vim.list_extend(pattern, vim.treesitter.language.get_filetypes(parser))
            end
        end

        local group = vim.api.nvim_create_augroup("NvimTreesitterFt", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = pattern,
            callback = function(ev)
                local max_filesize = 1024 * 1024
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
                if not (ok and stats and stats.size > max_filesize) then
                    vim.treesitter.start()
                    if vim.bo.filetype ~= "dart" then
                        -- Conflicts with flutter-tools.nvim, causing performance issues
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end
            end,
        })

        local rainbow_delimiters = require "rainbow-delimiters"

        vim.g.rainbow_delimiters = {
            strategy = {
                [""] = rainbow_delimiters.strategy["global"],
                vim = rainbow_delimiters.strategy["local"],
            },
            query = {
                [""] = "rainbow-delimiters",
                lua = "rainbow-blocks",
            },
            highlight = {
                "RainbowDelimiterRed",
                "RainbowDelimiterYellow",
                "RainbowDelimiterBlue",
                "RainbowDelimiterOrange",
                "RainbowDelimiterGreen",
                "RainbowDelimiterViolet",
                "RainbowDelimiterCyan",
            },
        }
        rainbow_delimiters.enable()

        -- In markdown files, the rendered output would only display the correct highlight if the code is set to scheme
        -- However, this would result in incorrect highlight in neovim
        -- Therefore, the scheme language should be linked to query
        vim.treesitter.language.register("query", "scheme")

        vim.api.nvim_exec_autocmds("User", { pattern = "XzwNvimAfter nvim-treesitter" })
        vim.api.nvim_exec_autocmds("FileType", { group = "NvimTreesitterFt" })
    end,
}

-- sourround
config.surround = {
    "kylechui/nvim-surround",
    version = "*",
    opts = {
        keymaps = {
            insert = "<C-c>s",
            insert_line = "<C-c>S",
        },
    },
    event = "User XzwNvimLoad",
}

-- telescope(文件、符号检索)
config.telescope = {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && "
                .. "cmake --build build --config Release && "
                .. "cmake --install build --prefix build",
        },
    },
    -- ensure that other plugins that use telescope can function properly
    cmd = "Telescope",
    opts = {
        defaults = {
            initial_mode = "insert",
            mappings = {
                i = {
                    -- 插入模式下映射
                    ["<C-j>"] = "move_selection_next",
                    ["<C-k>"] = "move_selection_previous",
                    ["<C-n>"] = "cycle_history_next",
                    ["<C-p>"] = "cycle_history_prev",
                    ["<C-c>"] = "close",
                    ["<C-u>"] = "preview_scrolling_up",
                    ["<C-d>"] = "preview_scrolling_down",
                },
            },
        },
        pickers = {
            find_files = {
                winblend = 20,
            },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
            },
        },
    },
    config = function(_, opts)
        local telescope = require "telescope"
        telescope.setup(opts)
        telescope.load_extension "fzf"
    end,
    keys = {
        { "<leader>tf", "<Cmd>Telescope find_files<CR>", desc = "find file", silent = true },
        { "<leader>t<C-f>", "<Cmd>Telescope live_grep<CR>", desc = "live grep", silent = true },
        { "<leader>uc", require("plugins.utils").view_configuration, desc = "view configuration" },
    },
}

-- TODO comment
config["todo-comments"] = {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "User XzwNvimLoad",
    main = "todo-comments",
    opts = {},
    keys = {
        { "<leader>ut", "<Cmd>TodoTelescope<CR>", desc = "todo list", silent = true },
    },
}

-- code fold
config.ufo = {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
    },
    event = "VeryLazy",
    opts = {
        preview = {
            win_config = {
                border = "rounded",
                winhighlight = "Normal:Folded",
                winblend = 0,
            },
        },
    },
    config = function(_, opts)
        vim.opt.foldenable = true

        require("ufo").setup(opts)
    end,
    keys = {
        {
            "zR",
            function()
                require("ufo").openAllFolds()
            end,
            desc = "Open all folds",
        },
        {
            "zM",
            function()
                require("ufo").closeAllFolds()
            end,
            desc = "Close all folds",
        },
        {
            "zp",
            function()
                require("ufo").peekFoldedLinesUnderCursor()
            end,
            desc = "Preview folded content",
        },
    },
}

-- undo tree
config.undotree = {
    "mbbill/undotree",
    config = function()
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_TreeNodeShape = "-"
    end,
    keys = {
        { "<leader>uu", "<Cmd>UndotreeToggle<CR>", desc = "undo tree toggle", silent = true },
    },
}

-- whichkey
config["which-key"] = {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        icons = {
            mappings = false,
        },
        plugins = {
            marks = true,
            registers = true,
            spelling = {
                enabled = false,
            },
            presets = {
                operators = false,
                motions = true,
                text_objects = true,
                windows = true,
                nav = true,
                z = true,
                g = true,
            },
        },
        spec = {
            -- { "<leader>a", group = "+avante" },
            { "<leader>b", group = "+buffer" },
            { "<leader>c", group = "+comment" },
            { "<leader>g", group = "+git" },
            { "<leader>h", group = "+hop" },
            { "<leader>l", group = "+lsp" },
            { "<leader>t", group = "+telescope" },
            { "<leader>u", group = "+utils" },
        },
        win = {
            border = "none",
            padding = { 1, 0, 1, 0 },
            wo = {
                winblend = 0,
            },
            zindex = 1000,
        },
    },
}

-- winsep(窗口分割线)
config.winsep = {
    "nvim-zh/colorful-winsep.nvim",
    event = "User XzwNvimAfter colorscheme",
    opts = {
        border = "single",
        highlight = function()
            vim.cmd "highlight link ColorfulWinsep IceNormal"
        end,
        animate = {
            enabled = false,
        },
    },
}

-- colorschemes
config["tokyonight"] = {
    "folke/tokyonight.nvim",
    lazy = true
}

XzwNvim.plugins = config

