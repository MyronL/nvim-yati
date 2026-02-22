local config = require("nvim-yati.config")
local internal = require("nvim-yati.internal")

local M = {}

---@param opts YatiUserConfig|nil
function M.setup(opts)
  config.setup(opts)
  internal.enable()

  -- Retroactively attach to already-open buffers (for lazy-loading scenarios)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype ~= "" then
      local ft = vim.bo[bufnr].filetype
      local lang = vim.treesitter.language.get_lang(ft) or ft
      internal.attach(bufnr, lang)
    end
  end
end

-- No-op for backward compat during transition
function M.init() end

return M
