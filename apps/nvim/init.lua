vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Apply dynamically generated custom theme overrides (Synchronous to eliminate FOUC)
local uv = vim.uv or vim.loop
local home = os.getenv("HOME") or os.getenv("USERPROFILE") or ""
local candidates = {}

-- 1. Thử lấy từ biến môi trường
local env_dotfiles = os.getenv("DOTFILES_DIR")
if env_dotfiles and env_dotfiles ~= "" then
  table.insert(candidates, env_dotfiles .. "/themes/generated/theme.lua")
end

-- 2. Fallback paths
if home ~= "" then
  table.insert(candidates, home .. "/.dotfiles/themes/generated/theme.lua")
  table.insert(candidates, home .. "/.config/themes/generated/theme.lua")
end

-- Tìm file theme hợp lệ
local theme_path = nil
for _, path in ipairs(candidates) do
  if uv.fs_stat(path) then
    theme_path = path
    break
  end
end

-- Áp dụng theme đồng bộ ngay khi khởi động
if theme_path then
  local success, theme = pcall(dofile, theme_path)
  if success and type(theme) == "table" then
    vim.api.nvim_set_hl(0, "Normal", { bg = theme.bg, fg = theme.fg })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = theme.bg })
    vim.api.nvim_set_hl(0, "LineNr", { fg = theme.black })
  end
end