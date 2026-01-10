--[[
    lsp/plugins.lua
    description: plugins used in lsp
--]]
local symbols = XzwNvim.symbols

-- mason: LSP Install and Manager
XzwNvim.plugins.mason = {
    "mason-org/mason.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mason-org/mason-lspconfig.nvim",
    },
    event = "User XzwNvimLoad",
    cmd = "Mason",
    opts = {
        ui = {
            icons = {
                package_installed = symbols.Affirmative,
                package_pending = symbols.Pending,
                package_uninstalled = symbols.Negative,
            },
        },
    },
    config = function(_, opts)
        require("mason").setup(opts)

        local registry = require "mason-registry"

        local package_list = registry.get_all_package_names()
        if #package_list == 0 then
            registry.refresh()
        end

        local function install(package)
            local s, p = pcall(registry.get_package, package)
            if s and not p:is_installed() then
                p:install()
            end
        end

        -- LSP 名称 -> 配置名称 映射
        local mason_lspconfig_mapping = require("mason-lspconfig").get_mappings().package_to_lspconfig

        local installed_packages = registry.get_installed_package_names()

        -- Download & Setting LSP 
        for lsp, config in pairs(XzwNvim.lsp) do
            if not config.enabled then
                goto continue
            end

            local formatter = config.formatter
            
            if lsp == "clangd" then
                -- 使用系统 clangd(跳过 mason)
                local clangd_config = {}
                clangd_config.cmd = { "/usr/bin/clangd" }

                local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
                blink_capabilities.textDocument.foldingRange = {
                    dynamicRegistration = false,
                    lineFoldingOnly = true,
                }
                
                local custom_setup = config.setup or {}
                if type(custom_setup) == "function" then
                    custom_setup = custom_setup()
                end

                clangd_config = vim.tbl_deep_extend("force", clangd_config, {
                    capabilities = blink_capabilities,
                }, custom_setup)
                
                -- require("lspconfig").clangd.setup(clangd_config)
                vim.lsp.config("clangd", clangd_config)
            else
                install(lsp)
            end

            install(formatter)

            if not vim.tbl_contains(installed_packages, lsp) then
                goto continue
            end

            lsp = mason_lspconfig_mapping[lsp]
            if not config.managed_by_plugin and vim.lsp.config[lsp] ~= nil then
                local setup = config.setup
                if type(setup) == "function" then
                    setup = setup()
                elseif setup == nil then
                    setup = {}
                end

                -- 获取到当前 LSP 功能
                local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
                blink_capabilities.textDocument.foldingRange = {
                    dynamicRegistration = false,
                    lineFoldingOnly = true,
                }
                setup = vim.tbl_deep_extend("force", setup, {
                    capabilities = blink_capabilities,
                })

                vim.lsp.config(lsp, setup)
            end

            ::continue::
        end

        vim.diagnostic.config {
            update_in_insert = true,
            severity_sort = true, -- necessary for lspsaga's show_line_diagnostics to work
            virtual_text = true,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = symbols.Error,
                    [vim.diagnostic.severity.WARN] = symbols.Warn,
                    [vim.diagnostic.severity.HINT] = symbols.Hint,
                    [vim.diagnostic.severity.INFO] = symbols.Info,
                },
                numhl = {
                    [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
                    [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
                    [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
                    [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
                },
            },
        }

        vim.lsp.inlay_hint.enable()

        local function lsp_start()
            -- Do not directly call `LspStart` (although the code below is pretty much word-to-word copied from the command)
            -- The reason is that `LspStart` would raise an error if no matching server is configured. This becomes an issue
            -- when the first file we open does not have a matching server. Therefore, we gotta check whether a server
            -- exists first.
            local servers = {}
            local filetype = vim.bo.filetype
            ---@diagnostic disable-next-line: invisible
            for name, _ in pairs(vim.lsp.config._configs) do
                local filetypes = vim.lsp.config[name].filetypes
                if filetypes and vim.tbl_contains(filetypes, filetype) then
                    table.insert(servers, name)
                end
            end

            if #servers > 0 then
                vim.lsp.enable(servers)
            end
        end

        local augroup = vim.api.nvim_create_augroup("XzwNvimLsp", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            group = augroup,
            callback = lsp_start,
        })

        vim.api.nvim_create_autocmd("LspAttach", {
            group = augroup,
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if not client or client.name == "null-ls" then
                    return
                end
                local lspconfig_mapping = require("mason-lspconfig").get_mappings().lspconfig_to_package

                local cfg = XzwNvim.lsp[lspconfig_mapping[client.name]]
                if type(cfg) == "table" and type(cfg.setup) == "table" and type(cfg.setup.on_attach) == "function" then
                    XzwNvim.aaa = cfg.setup.on_attach
                    cfg.setup.on_attach(client, args.buf)
                end
            end,
        })

        lsp_start()
    end,
}