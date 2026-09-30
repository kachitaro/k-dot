require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<C-\\>", "<cmd>vsplit<CR>", { desc = "Chia dọc màn hình (Vertical Split)" })
map("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "Bật/tắt NvimTree" })
map({ "n", "i" }, "<C-e>", "<cmd>VietnameseToggle<CR>", { desc = "Toggle tiếng Việt (Telex/VNI)" })
map("n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to definition" })

map("n", "<F5>", function() require("dap").continue() end, { desc = "Debug: Start/Continue" })
map("n", "<F9>", function() require("dap").toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
map("n", "<F10>", function() require("dap").step_over() end, { desc = "Debug: Step Over" })
map("n", "<F11>", function() require("dap").step_into() end, { desc = "Debug: Step Into" })
map("n", "<F6>", function() require("dapui").toggle() end, { desc = "Debug: Toggle UI" })

map("n", "<F2>", function() vim.lsp.buf.rename() end, { desc = "LSP Rename" })