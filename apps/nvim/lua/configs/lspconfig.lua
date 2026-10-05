local nvconfig = require("nvchad.configs.lspconfig")

nvconfig.defaults()

vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
-- Cấu hình viền nổi bật (border) cho LSP Hover & Signature Help giống VS Code
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
})


local servers = { "html", "cssls", "ts_ls", "jsonls", "eslint" }

for _, lsp in ipairs(servers) do
  vim.lsp.config[lsp] = {
    on_attach = nvconfig.on_attach,
    on_init = nvconfig.on_init,
    capabilities = nvconfig.capabilities,
  }
  vim.lsp.enable(lsp)
end
