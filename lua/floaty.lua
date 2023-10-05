local config = {
  width = 0.5,
  height = 0.5,
  border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
  winhl = 'Normal:Normal,FloatBorder:Normal',
  runners = {},
}

local floaty_bufnr = nil
local running = false

-- Setup fresh window options
local function make_winopts()
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines - vim.o.cmdheight

  return {
    relative = 'editor',
    width = math.floor(editor_width * config.width),
    height = math.floor(editor_height * config.height),
    col = math.floor((1 - config.width) * editor_width / 2) - 1,
    row = math.floor((1 - config.height) * editor_height / 2) - 1,
    style = 'minimal',
    border = config.border,
  }
end

-- Kill the current terminal
local function kill()
  local current_buf = vim.api.nvim_get_current_buf()
  if current_buf == floaty_bufnr then
    local current_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_close(current_win, true)
    vim.api.nvim_buf_delete(current_buf, { force = true })
    floaty_bufnr = nil
    running = false
  end
end

-- Create a new terminal and send in the given cmd
local function create_new(shell, cmd, win_opts)
  floaty_bufnr = vim.api.nvim_create_buf(false, true)
  local floaty_winid = vim.api.nvim_open_win(floaty_bufnr, true, win_opts)
  vim.api.nvim_win_set_option(floaty_winid, 'winhl', config.winhl)
  vim.bo.filetype = 'Floaty'
  local term_buf = vim.fn.termopen(shell, {
    on_exit = function(_, _, event)
      if event == 'exit' then
        kill()
      end
    end,
  })
  if cmd ~= '' then
    vim.fn.chansend(term_buf, cmd .. '\n')
  end
  vim.cmd('startinsert')
  running = true
end

local M = {}

M.setup = function(user_config)
  -- Merge configs
  if user_config then
    config = vim.tbl_extend('force', config, user_config)
  end

  M.toggle = function()
    -- Create new and open
    if not running then
      create_new('zsh', '', make_winopts())
      return
    end
    -- Close current
    if vim.api.nvim_get_current_buf() == floaty_bufnr then
      vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
      return
    end
    -- Open existing
    vim.api.nvim_open_win(floaty_bufnr, true, make_winopts())
    vim.cmd('startinsert')
  end

  M.kill = kill

  -- Run the code in the current file
  M.run = function()
    if running then
      vim.notify('Floaty: there is a terminal running, close it before you run the code!', vim.log.levels.ERROR)
      return
    end
    local name = vim.api.nvim_buf_get_name(0)
    local ftype = vim.bo.filetype
    local runner = config.runners[ftype]
    if runner ~= nil then
      create_new('zsh', runner:gsub('{}', name), make_winopts())
    end
  end
end

return M
