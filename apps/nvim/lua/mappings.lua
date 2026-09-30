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

-- VS Code Style Mappings
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Lưu file" })
map("n", "<C-p>", "<cmd>Telescope find_files<CR>", { desc = "Mở nhanh file" })
map("n", "<C-S-p>", "<cmd>Telescope commands<CR>", { desc = "Command Palette" })
map("n", "<C-S-P>", "<cmd>Telescope commands<CR>", { desc = "Command Palette" })
map({ "n", "t" }, "<C-`>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggle", size = 0.3 }
end, { desc = "Bật/Tắt Terminal" })

map("n", "<A-Down>", "<cmd>m .+1<CR>==", { desc = "Chuyển dòng xuống" })
map("n", "<A-Up>", "<cmd>m .-2<CR>==", { desc = "Chuyển dòng lên" })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Chuyển khối dòng xuống" })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Chuyển khối dòng lên" })