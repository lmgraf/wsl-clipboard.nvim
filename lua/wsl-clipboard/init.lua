local scripts = require 'wsl-clipboard.scripts'

---@class Scripts
---@field setup fun(opts?: WslClipboardOpts)
local M = {}

-- [[ Helpers ]]

--- Get and clean the value from a register
---@param reg? string
---@return string[] lines
local function getreg(reg)
  -- get raw system reg value
  local raw = vim.fn.getreg(reg, false)

  if raw == '' then return {} end

  -- Remove null bytes ('%z') and carriage returns ('\r')
  local cleaned = raw:gsub('%z', ''):gsub('\r', '')

  -- Split into lines
  return vim.split(cleaned, '\n', { plain = true })
end

--- Copy a value to the Windows clipboard
---@param value any
local function copy_to_windows(value)
  -- Runs the copy script with regcontents as stdin
  vim.system({ scripts.copy.get() }, { stdin = value })
end

--- Get the last copied value from the Windows clipboard
---@return string[] lines
local function paste_from_windows() return getreg '+' end

--- Callback to sync the Neovim clipboard with the latest value from Windows
local function sync_from_system()
  -- Paste 'linewise'
  vim.fn.setreg('"', paste_from_windows(), 'l')
end

--- Callback to sync the Windows clipboard with the latest value from Neovim
local function sync_to_system()
  -- "@" stands for the last used register
  copy_to_windows(vim.fn.getreg '@')
end

-- [[ Mode definitions ]]

--- Configures the native Neovim clipboard provider.
--- Most accurate mode as it manages registers natively, but has the highest
--- latency due to external process calls for every clipboard operation.
function M.setup_system()
  vim.o.clipboard = 'unnamedplus'

  local copy = scripts.copy.get()
  local paste = scripts.paste.get()

  vim.g.clipboard = {
    name = 'wsl-clipboard',
    copy = {
      ['+'] = copy,
      ['*'] = copy,
    },
    paste = {
      ['+'] = paste,
      ['*'] = paste,
    },
    cache_enabled = 0,
  }
end

--- Implements immediate-push and deferred-pull synchronization.
--- Outbound sync is as accurate as 'system' mode with much higher speed
--- Inbound sync depends on focus events and may be less reliable.
function M.setup_sync()
  -- Use internal registers for instant pasting
  vim.opt.clipboard = ''

  local group = vim.api.nvim_create_augroup('WslClipboardSync', { clear = true })

  vim.api.nvim_create_autocmd('TextYankPost', {
    group = group,
    callback = sync_to_system,
  })

  vim.api.nvim_create_autocmd('FocusGained', {
    group = group,
    callback = sync_from_system,
  })
end

--- Implements synchronization based on context switching.
--- Bridges clipboards only during focus changes to minimize overhead,
--- though perceived performance is comparable to 'sync' mode in WSL.
function M.setup_focus()
  vim.opt.clipboard = ''

  local group = vim.api.nvim_create_augroup('WslClipboardFocus', { clear = true })

  vim.api.nvim_create_autocmd('FocusLost', {
    group = group,
    callback = sync_to_system,
  })

  vim.api.nvim_create_autocmd('FocusGained', {
    group = group,
    callback = sync_from_system,
  })
end

---@class WslClipboardOpts
---@field mode? "system" | "sync" | "focus"

---@param opts? WslClipboardOpts
function M.setup(opts)
  opts = opts or {}
  local mode = opts.mode or 'system'

  if mode == 'system' then
    M.setup_system()
  elseif mode == 'sync' then
    M.setup_sync()
  elseif mode == 'focus' then
    M.setup_focus()
  else
    vim.notify('[wsl-clipboard] Invalid mode: ' .. tostring(mode), vim.log.levels.ERROR)
  end
end

return M
