local M = {}
local api = require("youtrack.core.api")
local utils = require("youtrack.utils")

function M.generate()
  vim.ui.select({
    "My Tasks Summary",
    "Project Progress",
    "Time Spent Analysis",
  }, {
    prompt = "Select report type:",
  }, function(choice)
    if choice == "My Tasks Summary" then
      M.my_tasks_summary()
    elseif choice == "Project Progress" then
      M.project_progress()
    elseif choice == "Time Spent Analysis" then
      M.time_spent_analysis()
    end
  end)
end

function M.my_tasks_summary()
  local tasks = api.get_my_tasks()
  local summary = {
    total = #tasks,
    by_status = {},
    by_priority = {},
  }

  for _, task in ipairs(tasks) do
    summary.by_status[task.status] = (summary.by_status[task.status] or 0) + 1
    summary.by_priority[task.priority] = (summary.by_priority[task.priority] or 0) + 1
  end

  -- Raporu görüntüle
  utils.display_report("My Tasks Summary", summary)
end

-- ... (project_progress ve time_spent_analysis fonksiyonları benzer şekilde implementa edilir)

return M
