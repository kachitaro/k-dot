---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "vscode_dark",
  hl_override = {
    -- Chuẩn màu VS Code Dark Modern: Editor #1f1f1f, Sidebar #181818
    Normal = { bg = "#1f1f1f", fg = "#cccccc" },
    NormalNC = { bg = "#1f1f1f" },
    -- Floating popup nổi bật tương phản cao giống VS Code Widget (#252526, viền sáng rõ nét)
    NormalFloat = { bg = "#252526", fg = "#e0e0e0" },
    FloatBorder = { bg = "#252526", fg = "#454545" }, -- viền xám sáng tách biệt hoàn toàn với nền #1f1f1f
    FloatTitle = { bg = "#252526", fg = "#4fc1ff", bold = true },
    -- Noice popup overrides
    NoicePopup = { bg = "#252526", fg = "#e0e0e0" },
    NoicePopupBorder = { bg = "#252526", fg = "#454545" },
    CursorLineNr = { fg = "#cccccc", bold = true },
    CursorLine = { bg = "#282828" },
    WinSeparator = { fg = "#2b2b2b", bg = "#1f1f1f" },

    -- Sidebar NvimTree màu tối hơn editor giống VS Code
    NvimTreeNormal = { bg = "#181818", fg = "#cccccc" },
    NvimTreeNormalNC = { bg = "#181818", fg = "#cccccc" },
    NvimTreeWinSeparator = { fg = "#2b2b2b", bg = "#181818" },
    NvimTreeCursorLine = { bg = "#2a2d2e" },
    NvimTreeIndentMarker = { fg = "#3b3b3b" },
    NvimTreeOpenedFolderName = { fg = "#cccccc", bold = true },
    NvimTreeFolderName = { fg = "#cccccc" },
    NvimTreeFolderIcon = { fg = "#dcb67a" },
    NvimTreeRootFolder = { fg = "#4fc1ff", bold = true },

    -- Màu trạng thái Git & Diagnostic trong NvimTree giống hệt VS Code:
    -- 1. File đã sửa (Modified): Màu vàng cam sáng #e2c08d / #cca700
    NvimTreeGitDirty = { fg = "#e2c08d" },
    -- 2. File mới / Untracked: Màu xanh lá cây #73c991
    NvimTreeGitNew = { fg = "#73c991" },
    -- 3. File đã xóa: Màu đỏ nhạt #c74e39
    NvimTreeGitDeleted = { fg = "#c74e39" },
    -- 4. File có lỗi (Error / Diagnostic): Màu đỏ #f14c4c
    NvimTreeDiagnosticErrorFileHL = { fg = "#f14c4c" },
    NvimTreeDiagnosticErrorFolderHL = { fg = "#f14c4c" },
    -- 5. File có cảnh báo (Warning): Màu vàng đậm #cca700
    NvimTreeDiagnosticWarnFileHL = { fg = "#cca700" },
    NvimTreeDiagnosticWarnFolderHL = { fg = "#cca700" },
    -- 6. File bị Git Ignore: Màu xám mờ #6e7681
    NvimTreeGitIgnored = { fg = "#6e7681" },

    -- Tabline (Tabufline) giống VS Code tab bar
    TbFill = { bg = "#181818" },
    Tabline = { bg = "#181818" },
    TbBufOn = { bg = "#1f1f1f", fg = "#ffffff", bold = true },
    TbBufOff = { bg = "#181818", fg = "#969696" },
    TbBufOnModified = { fg = "#4fc1ff", bg = "#1f1f1f" },
    TbBufOffModified = { fg = "#4fc1ff", bg = "#181818" },

    -- Statusline VS Code: xanh dương #007acc hoặc tối #181818
    StatusLine = { bg = "#181818", fg = "#cccccc" },
    StatusLineNC = { bg = "#181818", fg = "#6e7681" },
    St_Mode = { bg = "#007acc", fg = "#ffffff", bold = true },
    StText = { bg = "#181818", fg = "#cccccc" },

    -- Syntax chuẩn VS Code Dark Modern:
    Include = { fg = "#C586C0" }, -- 'import', 'export', 'from' màu hồng tím #C586C0
    Keyword = { fg = "#569CD6" }, -- 'const', 'interface', 'extends' màu xanh dương #569CD6
    Type = { fg = "#4EC9B0" },    -- 'React', 'Promise', Type names màu ngọc lục bảo #4EC9B0
    Function = { fg = "#DCDCAA" },-- tên hàm màu vàng kem #DCDCAA
    String = { fg = "#CE9178" },  -- chuỗi màu cam nâu #CE9178
    Number = { fg = "#B5CEA8" },  -- số màu xanh nhạt #B5CEA8
    Boolean = { fg = "#569CD6" }, -- true / false màu xanh dương
    Identifier = { fg = "#9CDCFE" }, -- biến màu xanh nhạt #9CDCFE
    Operator = { fg = "#D4D4D4" },-- toán tử màu xám trắng

    -- Treesitter mappings
    ["@keyword.import"] = { fg = "#C586C0" },
    ["@keyword.export"] = { fg = "#C586C0" },
    ["@keyword"] = { fg = "#569CD6" },
    ["@keyword.function"] = { fg = "#569CD6" },
    ["@keyword.return"] = { fg = "#C586C0" },
    ["@keyword.conditional"] = { fg = "#C586C0" },
    ["@keyword.repeat"] = { fg = "#C586C0" },
    ["@keyword.exception"] = { fg = "#C586C0" },
    ["@type"] = { fg = "#4EC9B0" },
    ["@type.builtin"] = { fg = "#4EC9B0" },
    ["@function"] = { fg = "#DCDCAA" },
    ["@function.call"] = { fg = "#DCDCAA" },
    ["@function.method"] = { fg = "#DCDCAA" },
    ["@function.method.call"] = { fg = "#DCDCAA" },
    ["@variable"] = { fg = "#9CDCFE" },
    ["@variable.parameter"] = { fg = "#9CDCFE" },
    ["@variable.member"] = { fg = "#9CDCFE" },
    ["@variable.member.key"] = { fg = "#9CDCFE" },
    ["@property"] = { fg = "#9CDCFE" },
    ["@tag"] = { fg = "#569CD6" },
    ["@tag.attribute"] = { fg = "#9CDCFE" },
    ["@tag.delimiter"] = { fg = "#808080" },
    ["@string"] = { fg = "#CE9178" },
  },
}

M.ui = {
  statusline = {
    theme = "vscode", -- Thanh statusline kiểu phẳng tối giản của VS Code
  },
  tabufline = {
    enabled = true,
    lazyload = false,
  },
}
return M
