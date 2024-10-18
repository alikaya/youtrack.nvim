local M = {}
local utils = require("youtrack.utils")

function M.create_branch_from_task(task_id)
  local current_instance = require("youtrack").instances[require("youtrack.config").options.current_instance]
  local task = current_instance:get_task(task_id)
  if not task then
    utils.notify("Task not found: " .. task_id, vim.log.levels.ERROR)
    return
  end

  local branch_name = string.lower(task_id .. "-" .. task.summary:gsub("%s+", "-"):gsub("[^%w-]", ""))

  local result = vim.fn.system({ "git", "checkout", "-b", branch_name })
  if vim.v.shell_error ~= 0 then
    utils.notify("Failed to create git branch: " .. result, vim.log.levels.ERROR)
  else
    utils.notify("Created git branch: " .. branch_name, vim.log.levels.INFO)
  end
end

function M.commit_with_task_id(task_id)
  local current_instance = require("youtrack").instances[require("youtrack.config").options.current_instance]
  local task = current_instance:get_task(task_id)
  if not task then
    utils.notify("Task not found: " .. task_id, vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = "Enter commit message: " }, function(input)
    if input then
      local commit_message = string.format("[%s] %s", task_id, input)
      local result = vim.fn.system({ "git", "commit", "-m", commit_message })
      if vim.v.shell_error ~= 0 then
        utils.notify("Failed to create commit: " .. result, vim.log.levels.ERROR)
      else
        utils.notify("Created commit: " .. commit_message, vim.log.levels.INFO)
      end
    end
  end)
end

return M
