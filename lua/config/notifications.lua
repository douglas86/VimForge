-- ~/.config/nvim/init.lua

local orig_notify = vim.notify

---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
  if type(msg) == "string" then
    -- Detect HTTP status codes starting with 4 or 5 (e.g., HTTP 429, status: 500)
    local code = msg:match("HTTP%s+([45]%d%d)")
              or msg:match("status%s*:%s*([45]%d%d)")
              or msg:match("([45]%d%d)%s+[%w_]+")

    if code then
      orig_notify("CodeCompanion: HTTP Error " .. code, vim.log.levels.WARN, opts)
      return
    end
  end
  orig_notify(msg, level, opts)
end
