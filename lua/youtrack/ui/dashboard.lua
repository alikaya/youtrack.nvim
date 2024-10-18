local M = {}
local api = require("youtrack.core.api")
local utils = require("youtrack.utils")
local config = require("youtrack.config")

function M.open()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = vim.o.columns
  local height = vim.o.lines

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width - 4,
    height = height - 4,
    col = 2,
    row = 2,
    style = "minimal",
    border = "rounded",
  })

  M.render(buf)

  -- Kısayol tuşları
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", opts)
  vim.api.nvim_buf_set_keymap(buf, "n", "r", ':lua require("youtrack.ui.dashboard").render()<CR>', opts)
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ':lua require("youtrack.ui.dashboard").select_item()<CR>', opts)

  -- Otomatik yenileme
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = buf,
    callback = function()
      M.render(buf)
    end,
  })
end

function M.render(buf)
  local current_instance = require("youtrack").instances[config.options.current_instance]
  utils.with_loading("Loading dashboard...", function()
    local my_tasks = current_instance:get_my_tasks()
    local recent_tasks = current_instance:get_my_tasks() -- Bu örnek için aynı API çağrısını kullanıyoruz

    local lines = {
      "Youtrack Dashboard",
      "",
      "My Tasks:",
    }

    for i, task in ipairs(my_tasks) do
      if i > 5 then
        break
      end
      table.insert(lines, string.format("  - [%s] %s", task.id, task.summary))
    end

    table.insert(lines, "")
    table.insert(lines, "Recent Tasks:")

    for i, task in ipairs(recent_tasks) do
      if i > 5 then
        break
      end
      table.insert(lines, string.format("  - [%s] %s", task.id, task.summary))
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end)

  vim.api.nvim_buf_add_highlight(buf, -1, "YoutrackHeader", 0, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, "YoutrackSubHeader", 2, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, "YoutrackSubHeader", #lines - 6, 0, -1)
end

function M.select_item()
  local line = vim.api.nvim_get_current_line()
  local task_id = line:match("%[(%w+-%d+)%]")
  if task_id then
    require("youtrack").show_task_details(task_id)
  end
end

return M
