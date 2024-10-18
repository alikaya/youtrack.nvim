local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local youtrack = require("youtrack")

local M = {}

M.projects = function(opts)
  opts = opts or {}
  pickers
      .new(opts, {
        prompt_title = "YouTrack Projects",
        finder = finders.new_table({
          results = opts.results or youtrack.cache.projects,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.name,
              ordinal = entry.name,
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            youtrack.list_tasks(selection.value.id)
          end)
          return true
        end,
      })
      :find()
end

M.tasks = function(opts)
  opts = opts or {}
  pickers
      .new(opts, {
        prompt_title = "YouTrack Tasks",
        finder = finders.new_table({
          results = opts.results,
          entry_maker = function(entry)
            return {
              value = entry,
              display = string.format("[%s] %s", entry.id, entry.summary),
              ordinal = entry.id .. " " .. entry.summary,
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            youtrack.show_task_details(selection.value.id)
          end)
          return true
        end,
      })
      :find()
end

M.statuses = function(opts)
  opts = opts or {}
  pickers
      .new(opts, {
        prompt_title = "YouTrack Task Statuses",
        finder = finders.new_table({
          results = opts.results,
          entry_maker = function(status)
            return {
              value = status,
              display = status.name,
              ordinal = status.name,
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = opts.attach_mappings,
      })
      :find()
end

return require("telescope").register_extension({
  exports = M,
})
