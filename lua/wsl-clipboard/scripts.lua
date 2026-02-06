---@class Scripts
---@field copy Scripts.Copy
---@field paste Scripts.Paste
local M = {}

---@class Scripts.Copy
M.copy = {}

---@class Scripts.Paste
M.paste = {}

---Get absolute path to a script
---@param name string name of the script
---@return string path Absolute path to the script
function M.get(name)
  local path = 'scripts/' .. name
  local matches = vim.api.nvim_get_runtime_file(path, false)
  if #matches == 0 then
    error(string.format('[wsl-clipboard] %s not found in runtimepath', path))
  end
  return matches[1]
end

---Get Windows clipboard copy script
---@return string path Absolute path to copy.sh
function M.copy.get() return M.get 'copy.sh' end

---Get Windows clipboard paste script
---@return string path Absolute path to paste.sh
function M.paste.get() return M.get 'paste.sh' end

return M
