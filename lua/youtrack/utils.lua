local M = {}

function M.notify(message, level)
  vim.notify(message, level, { title = "Youtrack" })
end

function M.with_loading(message, callback)
  vim.api.nvim_echo({ { message, "WarningMsg" } }, false, {})
  local result = callback()
  vim.api.nvim_echo({ { "", "None" } }, false, {})
  return result
end

function M.format_duration(seconds)
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60
  return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function M.debounce(func, wait)
  local timer = vim.loop.new_timer()
  return function(...)
    local args = { ... }
    timer:stop()
    timer:start(
      wait,
      0,
      vim.schedule_wrap(function()
        func(unpack(args))
      end)
    )
  end
end

function M.display_report(title, data)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })

  local lines = { title, string.rep("=", #title) }
  for k, v in pairs(data) do
    if type(v) == "table" then
      table.insert(lines, k .. ":")
      for subk, subv in pairs(v) do
        table.insert(lines, "  " .. subk .. ": " .. tostring(subv))
      end
    else
      table.insert(lines, k .. ": " .. tostring(v))
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -- Kısayol tuşu ekle
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
end

return M
