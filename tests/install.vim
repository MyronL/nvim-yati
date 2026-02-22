" https://github.com/neovim/neovim/issues/12432
set display=lastline

set packpath+=./deps
set rtp+=.

packloadall

lua << EOF
require("nvim-yati").setup({})

local test_langs = {
  "c",
  "cpp",
  "graphql",
  "html",
  "javascript",
  "json",
  "lua",
  "python",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vue",
}

for _, lang in ipairs(test_langs) do
  if #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) == 0 then
    vim.cmd("TSInstall! " .. lang)
  end
end
EOF
