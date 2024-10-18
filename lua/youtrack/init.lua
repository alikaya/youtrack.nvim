local M = {}
local api = require("youtrack.core.api")
local utils = require("youtrack.utils")
local config = require("youtrack.config")
local log = require("youtrack.log")
local job_queue = require("youtrack.job_queue")
local cache = require("youtrack.cache")
local dashboard = require("youtrack.ui.dashboard")
local lsp = require("youtrack.integrations.lsp")

M.instances = {}

function M.setup(opts)
  config.setup(opts)
  log.setup(config.options.log_level)
  job_queue.setup()
  cache.setup(config.options.cache_config)
  lsp.setup()

  -- Çoklu instance kurulumu
  for name, instance_config in pairs(config.options.instances) do
    M.instances[name] = api.new_instance(instance_config)
  end

  -- Telescope uzantısını yükle
  require("telescope").load_extension("youtrack")

  -- Dashboard'u otomatik olarak aç (eğer konfigürasyonda belirtilmişse)
  if config.options.auto_open_dashboard then
    dashboard.open()
  end

  -- Komutları kaydet
  vim.api.nvim_create_user_command("YoutrackSelectInstance", M.select_instance, {})
  vim.api.nvim_create_user_command("YoutrackProjects", M.list_projects, {})
  vim.api.nvim_create_user_command("YoutrackTasks", M.list_tasks, {})
  vim.api.nvim_create_user_command("YoutrackMyTasks", M.list_my_tasks, {})
  vim.api.nvim_create_user_command("YoutrackCreateTask", M.create_task, {})
  vim.api.nvim_create_user_command("YoutrackSearchTasks", M.search_tasks, {})
  vim.api.nvim_create_user_command("YoutrackDashboard", dashboard.open, {})
  vim.api.nvim_create_user_command("YoutrackTimeTracker", require("youtrack.time_tracker").toggle, {})
  vim.api.nvim_create_user_command("YoutrackReport", require("youtrack.reports").generate, {})
  vim.api.nvim_create_user_command(
    "YoutrackGitBranch",
    require("youtrack.integrations.git").create_branch_from_task,
    {}
  )

  -- Özelleştirilebilir kısayol tuşlarını ayarla
  for action, key in pairs(config.options.keymaps) do
    vim.api.nvim_set_keymap(
      "n",
      key,
      string.format("<cmd>lua require('youtrack').%s()<CR>", action),
      { noremap = true, silent = true }
    )
  end
end

function M.select_instance()
  local instance_names = vim.tbl_keys(M.instances)
  vim.ui.select(instance_names, {
    prompt = "Select Youtrack Instance:",
  }, function(choice)
    if choice then
      config.options.current_instance = choice
      utils.notify("Switched to Youtrack instance: " .. choice, vim.log.levels.INFO)
    end
  end)
end

function M.list_projects()
  local current_instance = M.instances[config.options.current_instance]
  job_queue.push({
    name = "list_projects",
    fn = function()
      local projects = cache.get_or_set("projects", function()
        return current_instance:get_projects()
      end)
      require("telescope").extensions.youtrack.projects(projects)
    end,
    on_error = function(err)
      log.error("Failed to list projects: " .. err)
      utils.notify("Failed to list projects. Check logs for details.", vim.log.levels.ERROR)
    end,
  })
end

function M.list_tasks(project_id)
  local current_instance = M.instances[config.options.current_instance]
  job_queue.push({
    name = "list_tasks",
    fn = function()
      local tasks = cache.get_or_set("tasks_" .. project_id, function()
        return current_instance:get_tasks(project_id)
      end)
      require("telescope").extensions.youtrack.tasks(tasks)
    end,
    on_error = function(err)
      log.error("Failed to list tasks: " .. err)
      utils.notify("Failed to list tasks. Check logs for details.", vim.log.levels.ERROR)
    end,
  })
end

function M.list_my_tasks()
  local current_instance = M.instances[config.options.current_instance]
  job_queue.push({
    name = "list_my_tasks",
    fn = function()
      local tasks = cache.get_or_set("my_tasks", function()
        return current_instance:get_my_tasks()
      end)
      require("telescope").extensions.youtrack.tasks(tasks)
    end,
    on_error = function(err)
      log.error("Failed to list my tasks: " .. err)
      utils.notify("Failed to list my tasks. Check logs for details.", vim.log.levels.ERROR)
    end,
  })
end

function M.create_task()
  local current_instance = M.instances[config.options.current_instance]
  vim.ui.input({ prompt = "Enter project ID: " }, function(project_id)
    if not project_id then
      return
    end

    vim.ui.input({ prompt = "Enter task summary: " }, function(summary)
      if not summary then
        return
      end

      vim.ui.input({ prompt = "Enter task description: " }, function(description)
        job_queue.push({
          name = "create_task",
          fn = function()
            local new_task = current_instance:create_task(project_id, summary, description)
            utils.notify("Task created: " .. new_task.id, vim.log.levels.INFO)
            M.show_task_details(new_task.id)
          end,
          on_error = function(err)
            log.error("Failed to create task: " .. err)
            utils.notify("Failed to create task. Check logs for details.", vim.log.levels.ERROR)
          end,
        })
      end)
    end)
  end)
end

function M.search_tasks()
  local current_instance = M.instances[config.options.current_instance]
  vim.ui.input({ prompt = "Enter search query: " }, function(query)
    if query then
      job_queue.push({
        name = "search_tasks",
        fn = function()
          local tasks = current_instance:search_tasks(query)
          require("telescope").extensions.youtrack.tasks(tasks)
        end,
        on_error = function(err)
          log.error("Failed to search tasks: " .. err)
          utils.notify("Failed to search tasks. Check logs for details.", vim.log.levels.ERROR)
        end,
      })
    end
  end)
end

function M.show_task_details(task_id)
  local current_instance = M.instances[config.options.current_instance]
  job_queue.push({
    name = "show_task_details",
    fn = function()
      local task = current_instance:get_task(task_id)
      require("youtrack.ui.task_details").show(task)
    end,
    on_error = function(err)
      log.error("Failed to show task details: " .. err)
      utils.notify("Failed to show task details. Check logs for details.", vim.log.levels.ERROR)
    end,
  })
end

return M
