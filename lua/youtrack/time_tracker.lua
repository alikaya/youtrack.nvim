local M = {}
local api = require("youtrack.core.api")
local utils = require("youtrack.utils")

local active_task = nil
local start_time = nil

function M.setup()
  -- Herhangi bir başlangıç konfigürasyonu gerekirse buraya eklenebilir
end

function M.start(task_id)
  if active_task then
    M.stop()
  end
  active_task = task_id
  start_time = os.time()
  utils.notify("Started time tracking for task: " .. task_id, vim.log.levels.INFO)
end

function M.stop()
  if active_task then
    local duration = os.time() - start_time
    api.log_work_item(active_task, duration)
    utils.notify("Logged " .. utils.format_duration(duration) .. " for task: " .. active_task, vim.log.levels.INFO)
    active_task = nil
    start_time = nil
  end
end

function M.toggle()
  if active_task then
    M.stop()
  else
    vim.ui.input({ prompt = "Enter task ID to track: " }, function(input)
      if input then
        M.start(input)
      end
    end)
  end
end

return M
