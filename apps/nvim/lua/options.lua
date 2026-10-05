require "nvchad.options"
-- Thời gian dừng con trỏ trước khi kích hoạt CursorHold (ms) - giống tốc độ hover của VS Code
vim.opt.updatetime = 300

-- Tối ưu cuộn chuột và di chuyển buffer mượt mà giống VS Code
vim.opt.scrolloff = 8         -- Giữ tối thiểu 8 dòng lề trên/dưới khi cuộn (không bị khựng cạnh màn hình)
vim.opt.sidescrolloff = 8     -- Giữ 8 cột lề trái/phải khi cuộn ngang
vim.opt.mousescroll = "ver:3,hor:3" -- Tốc độ cuộn chuột đều, không bị nhảy giật
