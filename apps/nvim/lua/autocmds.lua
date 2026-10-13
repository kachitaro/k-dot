require "nvchad.autocmds"

-- Tự động mở file ảnh bằng trình xem ảnh hệ thống và đóng buffer nhị phân (Cách 2)
vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = { "*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif", "*.ico", "*.bmp", "*.svg" },
  callback = function(args)
    local file_path = vim.api.nvim_buf_get_name(args.buf)
    if file_path and file_path ~= "" then
      vim.fn.jobstart({ "xdg-open", file_path }, { detach = true })
    end
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        vim.cmd("silent! bdelete! " .. args.buf)
      end
    end)
  end,
})

-- Tự động hiện popup hover khi dừng con trỏ chuột/phím (giống VS Code Hover)
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    -- Chỉ chạy khi có LSP client đính kèm buffer hiện tại
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then return end

    -- Tránh bật đè khi đang ở trong popup floating window hoặc insert mode
    if vim.fn.mode() ~= "n" then return end
    local win_config = vim.api.nvim_win_get_config(0)
    if win_config.relative ~= "" then return end

    -- Tự động mở hover popup với viền nổi bo góc giống VS Code
    vim.lsp.buf.hover({ focusable = false, border = "rounded" })
  end,
})

-- Tự động lưu file sau 5 giây không gõ phím (giống files.autoSave: afterDelay, autoSaveDelay: 5000 của VS Code)
local auto_save_timer = nil
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  callback = function(args)
    local bufnr = args.buf
    -- Chỉ auto save buffer file thông thường (không save terminal, prompt, nvimtree)
    if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modified or vim.bo[bufnr].readonly then
      return
    end

    -- Reset timer nếu người dùng tiếp tục gõ
    if auto_save_timer then
      auto_save_timer:stop()
    else
      auto_save_timer = vim.uv.new_timer()
    end

    -- Chờ 5000ms (5 giây) trước khi thực hiện silent write
    auto_save_timer:start(5000, 0, vim.schedule_wrap(function()
      if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].modified then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("silent! write")
        end)
      end
    end))
  end,
})

