local o = require("nvim-yati.config")

local M = {}
local stored_expr = {}
local augroup = vim.api.nvim_create_augroup("nvim_yati", { clear = true })

function M.attach(bufnr, lang)
  if not lang then
    local ft = vim.bo[bufnr].filetype
    lang = vim.treesitter.language.get_lang(ft) or ft
  end
  if not o.is_supported(lang) then
    return
  end
  stored_expr[bufnr] = vim.bo[bufnr].indentexpr
  vim.bo[bufnr].indentexpr = "v:lua.require'nvim-yati.indent'.indentexpr()"
end

function M.detach(bufnr)
  if stored_expr[bufnr] ~= nil then
    vim.bo[bufnr].indentexpr = stored_expr[bufnr]
    stored_expr[bufnr] = nil
  end
end

function M.enable()
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    callback = function(args)
      local bufnr = args.buf
      local ft = args.match
      local lang = vim.treesitter.language.get_lang(ft) or ft
      M.attach(bufnr, lang)
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = augroup,
    callback = function(args)
      stored_expr[args.buf] = nil
    end,
  })
end

function M.disable()
  vim.api.nvim_clear_autocmds({ group = augroup })
  for bufnr, _ in pairs(stored_expr) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      M.detach(bufnr)
    end
  end
  stored_expr = {}
end

return M
