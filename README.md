# Floaty.nvim

## Install

For example, with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use('devkvlt/floaty.nvim')
```

## Setup

```lua
require('floaty').setup()
```

This sets up Floaty with the following defaults:

```lua
config = {
  width = 0.5, -- Number between 0 and 1 representing a percentage of the editor's width
  height = 0.5, -- Same as above
  border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }, -- Chars for the window borders
  winhl = 'Normal:Normal,FloatBorder:Normal', -- Highlight group for the window and the borders, see `h: winhl`
  runners = {}, -- Commands to execute code per (filetype,) see below
}
```

## Code runners

Example:

```lua
require('floaty').setup({
  runners = {
    c = 'gcc {} && ./a.out',
    go = 'go run {}',
    html = 'open {}',
    javascript = 'node {}',
    lua = 'lua {}',
    python = 'python3 {}',
    rust = 'rustc {} -o a.out && ./a.out',
    sh = 'bash {}',
    typescript = 'deno run {}',
  },
})
```

`{}` is the name of the file to run.

## Keymaps

Floaty exposes 3 functions which can be used to create keymaps, for example:

```lua
local floaty = require('floaty')

vim.keymap.set({ 'n', 't' }, '<A-\\>', floaty.toggle, { silent = true })
vim.keymap.set('t', '<Esc>', floaty.kill, { silent = true })
vim.keymap.set('n', ' r', floaty.run, { silent = true })
```
