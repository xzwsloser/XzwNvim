XzwNvim.plugins["nvim-dap"] = {
    "mfussenegger/nvim-dap",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
    },

    config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        
        dapui.setup()
    
        -- adapters 配置
        dap.adapters.gdb = {
            type = "executable",
            command = "gdb",
            args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
        }

        dap.configurations.c = {
            {
                name = "Launch",
                type = "gdb",
                request = "launch",
                program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                args = {}, -- provide arguments if needed
                cwd = "${workspaceFolder}",
                stopAtBeginningOfMainSubprogram = true,
            },
            {
                name = "Select and attach to process",
                type = "gdb",
                request = "attach",
                program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                pid = function()
                local name = vim.fn.input('Executable name (filter): ')
                return require("dap.utils").pick_process({ filter = name })
                end,
                cwd = '${workspaceFolder}'
            },
            {
                name = 'Attach to gdbserver :1234',
                type = 'gdb',
                request = 'attach',
                target = 'localhost:1234',
                program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}'
            }
        }

        dap.configurations.cpp = dap.configurations.c

        vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end)
        vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end)
        vim.keymap.set('n', '<leader>dc',  function() require('dap').continue() end)
        vim.keymap.set('n', '<leader>do', function() require('dap').step_over() end)
        vim.keymap.set('n', '<leader>di', function() require('dap').step_into() end)
        vim.keymap.set('n', '<leader>dt', '<Cmd>DapTerminate<CR>')
    end,
} 

