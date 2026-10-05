require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<C-\\>", "<cmd>vsplit<CR>", { desc = "Chia dọc màn hình (Vertical Split)" })
map("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "Bật/tắt NvimTree" })
map({ "n", "i" }, "<C-e>", "<cmd>VietnameseToggle<CR>", { desc = "Toggle tiếng Việt (Telex/VNI)" })
map("n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to definition" })
-- LSP Hover popup (hiển thị popup thông tin type/hàm giống VS Code hover)
map("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover popup giống VS Code" })
map("n", "<leader>k", vim.lsp.buf.hover, { desc = "LSP Hover popup giống VS Code" })

-- Window navigation (Chuyển cửa sổ giữa Sidebar NvimTree và Buffers)
map({ "n", "t" }, "<C-S-Left>", "<cmd>wincmd h<CR>", { desc = "Chuyển sang cửa sổ bên trái" })
map({ "n", "t" }, "<C-S-Right>", "<cmd>wincmd l<CR>", { desc = "Chuyển sang cửa sổ bên phải" })
map({ "n", "t" }, "<C-S-Up>", "<cmd>wincmd k<CR>", { desc = "Chuyển sang cửa sổ bên trên" })
map({ "n", "t" }, "<C-S-Down>", "<cmd>wincmd j<CR>", { desc = "Chuyển sang cửa sổ bên dưới" })

-- Hỗ trợ thêm Ctrl + Mũi tên (tiện lợi, phổ biến)
map({ "n", "t" }, "<C-Left>", "<cmd>wincmd h<CR>", { desc = "Chuyển sang cửa sổ bên trái" })
map({ "n", "t" }, "<C-Right>", "<cmd>wincmd l<CR>", { desc = "Chuyển sang cửa sổ bên phải" })
map({ "n", "t" }, "<C-Up>", "<cmd>wincmd k<CR>", { desc = "Chuyển sang cửa sổ bên trên" })
map({ "n", "t" }, "<C-Down>", "<cmd>wincmd j<CR>", { desc = "Chuyển sang cửa sổ bên dưới" })


map("n", "<F5>", function() require("dap").continue() end, { desc = "Debug: Start/Continue" })
map("n", "<F9>", function() require("dap").toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
map("n", "<F10>", function() require("dap").step_over() end, { desc = "Debug: Step Over" })
map("n", "<F11>", function() require("dap").step_into() end, { desc = "Debug: Step Into" })
map("n", "<F6>", function() require("dapui").toggle() end, { desc = "Debug: Toggle UI" })

map("n", "<F2>", function() vim.lsp.buf.rename() end, { desc = "LSP Rename" })
-- Hàm sắp xếp import và tự động định dạng bằng Prettier (Organize Imports + Prettier Format)
local function organize_imports()
  local bufnr = vim.api.nvim_get_current_buf()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(bufnr) },
    title = "",
  }

  -- 1. Thử gửi lệnh tới TypeScript Language Server
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local handled = false
  for _, client in ipairs(clients) do
    if client.name == "ts_ls" or client.name == "typescript-tools" or client.name == "vtsls" then
      client:exec_cmd(params, { bufnr = bufnr })
      handled = true
      break
    end
  end

  -- 2. Fallback sang Code Action `source.organizeImports` nếu chưa được xử lý
  if not handled then
    vim.lsp.buf.code_action({
      context = { only = { "source.organizeImports" }, diagnostics = {} },
      apply = true,
    })
  end

  -- 3. Tự động chạy Prettier (thông qua conform.nvim) sau khi sắp xếp xong
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      local ok, conform = pcall(require, "conform")
      if ok then
        conform.format({ bufnr = bufnr, lsp_fallback = true })
      else
        vim.lsp.buf.format({ bufnr = bufnr, async = true })
      end
    end
  end, 150)
end

-- Tạo user command :OrganizeImports để hiện trong Telescope Command Palette (Ctrl+Shift+P)
vim.api.nvim_create_user_command("OrganizeImports", organize_imports, { desc = "Sắp xếp imports (Organize Imports)" })

-- Gán phím tắt nhanh giống VS Code (Shift + Alt + O)
map("n", "<A-S-o>", organize_imports, { desc = "Organize Imports (VS Code Shift+Alt+O)" })
map("n", "<A-S-O>", organize_imports, { desc = "Organize Imports (VS Code Shift+Alt+O)" })
map("n", "<leader>oi", organize_imports, { desc = "Organize Imports" })

-- Bản đồ cấu trúc hàm & biến Symbol Outline (Aerial - giống Outline VS Code)
map("n", "<leader>o", "<cmd>AerialToggle!<CR>", { desc = "Bật/Tắt Code Outline (Symbol Map)" })
map("n", "<A-o>", "<cmd>AerialToggle!<CR>", { desc = "Bật/Tắt Code Outline (Symbol Map)" })

-- VS Code Style Mappings
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Lưu file" })
map("n", "<C-p>", "<cmd>Telescope find_files<CR>", { desc = "Mở nhanh file" })
map("n", "<C-S-p>", "<cmd>Telescope commands<CR>", { desc = "Command Palette" })
map("n", "<C-S-P>", "<cmd>Telescope commands<CR>", { desc = "Command Palette" })
map("n", "<C-w>", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Đóng buffer hiện tại (giống VS Code Ctrl+W)" })

map({ "n", "t" }, "<C-`>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggle", size = 0.3 }
end, { desc = "Bật/Tắt Terminal" })

map("n", "<A-Down>", "<cmd>m .+1<CR>==", { desc = "Chuyển dòng xuống" })
map("n", "<A-Up>", "<cmd>m .-2<CR>==", { desc = "Chuyển dòng lên" })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Chuyển khối dòng xuống" })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Chuyển khối dòng lên" })