# nvim-yati

A fork of [yioneko/nvim-yati](https://github.com/yioneko/nvim-yati) — yet another tree-sitter indent plugin for Neovim.

This fork updates the plugin to work with the nvim-treesitter `main` branch, which removed the old module system (`define_modules`, `nvim-treesitter.configs.setup()`, etc.). The plugin now uses a standalone `setup()` function and manages its own lifecycle via autocommands.

If the builtin nvim-treesitter indent module already satisfies you, this plugin is likely unnecessary. Otherwise, take a glance at [features](#features) to learn about the differences.

<details>
  <summary>
    <b>Supported languages</b>
  </summary>

- C/C++
- CSS
- GraphQL
- HTML
- Javascript/Typescript (jsx and tsx are also supported)
- JSON
- Lua
- Python
- Rust
- TOML
- Vue

</details>

More languages could be supported by [setup](#setup) or adding config files to [configs/](lua/nvim-yati/configs) directory.

## Compatibility

Requires **Neovim 0.11+** and **nvim-treesitter `main` branch**.

This plugin is always developed based on latest neovim and nvim-treesitter. Please consider upgrading them if there is any compatibility issue.

## Installation

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "MyronL/nvim-yati",
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = function()
    require("nvim-yati").setup({})
  end,
}
```

[vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'MyronL/nvim-yati'
```

Then add `require("nvim-yati").setup({})` to your `init.lua`.

## Setup

Add the following to your Neovim config:

```lua
require("nvim-yati").setup({
  -- Disable by languages, see `Supported languages`
  disable = { "python" },

  -- Whether to enable lazy mode (recommend to enable this if bad indent happens frequently)
  default_lazy = true,

  -- Determine the fallback method used when we cannot calculate indent by tree-sitter
  --   "auto": fallback to vim auto indent
  --   "asis": use current indent as-is
  --   "cindent": see `:h cindent()`
  -- Or a custom function return the final indent result.
  default_fallback = "auto",
})
```

The original author also created a regex-based indent plugin ([vim-tmindent](https://github.com/yioneko/vim-tmindent)) for saner fallback indent calculation, which could be a drop-in replacement of the builtin indent method. See [integration](https://github.com/yioneko/vim-tmindent#nvim-yati) for its fallback setup.

Example for a more customized setup:

```lua
local get_builtin = require("nvim-yati.config").get_builtin
-- This is just an example, not recommend to do this since the result is unpredictable
local js_overrides = vim.tbl_deep_extend("force", get_builtin("javascript"), {
  lazy = false,
  fallback = function() return -1 end,
  nodes = {
    ["if_statement"] = { "scope" }, -- set attributes by node
  },
  handlers = {
    on_initial = {},
    on_travers = {
      function(ctx) return false end, -- set custom handlers
    }
  }
})

require("nvim-yati").setup({
  disable = { "python" },
  default_lazy = false,
  default_fallback = function() return -1 end, -- provide custom fallback indent method
  overrides = {
    javascript = js_overrides -- override config by language
  },
})
```

More technical details goes there (**highly unstable**): [CONFIG.md](./CONFIG.md).

## Features

- Fast, match node on demand by implementing completely in Lua, compared to executing scm query on the whole tree on every indent calculation.
- Could be faster and more context aware if `lazy` enabled, see `default_lazy` option. This is specifically useful if the surrounding code doesn't obey indent rules:

  ```lua
  function fun()
    if abc then
                  if cbd then
                    a() -- new indent will goes here even if the parent node indent wrongly
                  end
    end
  end
  ```

- Fallback indent method support to reuse calculated indent from tree.
- Support indent in injection region. See [sample.html](tests/fixtures/html/sample.html) for example.
- [Tests](tests/fixtures) covered and handles much more edge cases. Refer samples in that directory for what the indentation would be like. The style is slightly opinionated as there is no actual standard, but customization is still possible.
- Support for custom handlers to deal with complex scenarios. This plugin relies on dedicated handlers to fix many edge cases like the following one:

  ```python
  if True:
    pass
    else: # should auto dedent <-
          # the parsed tree is broken here and cannot be handled by tree-sitter
  ```

## Notes

- The calculation result heavily relies on the correct tree-sitter parsing of the code. I'd recommend using plugins like [nvim-autopairs](https://github.com/windwp/nvim-autopairs) or [luasnip](https://github.com/L3MON4D3/LuaSnip) to keep the syntax tree error-free while editing. This should avoid most of the wrong indent calculations.
- The original author mainly writes javascript so other languages may not receive as much support, and edge cases for other languages are expected. Please create issues for them if possible.

## Credits

- [yioneko/nvim-yati](https://github.com/yioneko/nvim-yati) for the original plugin.
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for initial aspiration and test cases.
- [chfritz/atom-sane-indentation](https://github.com/chfritz/atom-sane-indentation) for algorithm and test cases.
