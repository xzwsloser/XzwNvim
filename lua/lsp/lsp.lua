--[[
    lsp/lsp.lua
    description: lsp configuration for different language
--]]

local lsp = {}

lsp = {
    ["bash-language-server"] = {
        formatter = "shfmt",
        enabled = true,
    },

    clangd = {
        enabled = true,
    },

    gopls = {
        formatter = "gofumpt",
        setup = {
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                    },
                },
            },
        },
        enabled = true,
    },

    ["html-lsp"] = {
        formatter = "prettier",
        enabled = true,
    },

    ["json-lsp"] = {
        formatter = "prettier",
        enabled = true,
    },

    ["lua-language-server"] = {
        formatter = "stylua",
        setup = {
            settings = {
                Lua = {
                    runtime = {
                        version = "LuaJIT",
                        path = (function()
                            local runtime_path = vim.split(package.path, ";")
                            table.insert(runtime_path, "lua/?.lua")
                            table.insert(runtime_path, "lua/?/init.lua")
                            return runtime_path
                        end)(),
                    },
                    diagnostics = {
                        globals = { "vim" },
                    },
                    hint = {
                        enable = true,
                    },
                    workspace = {
                        library = {
                            vim.env.VIMRUNTIME,
                            "${3rd}/luv/library",
                        },
                        checkThirdParty = false,
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },
        },
        enabled = true,
    },

    pyright = {
        formatter = "black",
        enabled = true,
    },
}

XzwNvim.lsp = lsp



