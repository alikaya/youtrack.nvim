local M = {}
local curl = require("plenary.curl")
local utils = require("youtrack.utils")
local config = require("youtrack.config")

local function api_request(method, endpoint, body, instance_config)
  local url = instance_config.url .. endpoint
  local headers = {
    Authorization = "Bearer " .. instance_config.token,
    ["Content-Type"] = "application/json",
  }

  local response
  if method == "GET" then
    response = curl.get(url, { headers = headers })
  elseif method == "POST" then
    response = curl.post(url, { headers = headers, body = vim.fn.json_encode(body) })
  else
    error("Unsupported HTTP method: " .. method)
  end

  if response.status >= 400 then
    error("API Error: " .. response.body)
  end

  return vim.fn.json_decode(response.body)
end

function M.new_instance(instance_config)
  local instance = {}

  function instance:get_projects()
    return api_request("GET", "/api/projects?fields=id,name", nil, instance_config)
  end

  function instance:get_tasks(project_id)
    return api_request(
      "GET",
      "/api/issues?fields=id,summary,description&query=project:" .. project_id,
      nil,
      instance_config
    )
  end

  function instance:get_my_tasks()
    return api_request(
      "GET",
      "/api/issues?fields=id,summary,description,project(name)&query=for:me sort by: updated",
      nil,
      instance_config
    )
  end

  function instance:get_task(task_id)
    return api_request(
      "GET",
      "/api/issues/" .. task_id .. "?fields=id,summary,description,comments(text,author(name)),status(name)",
      nil,
      instance_config
    )
  end

  function instance:create_task(project_id, summary, description)
    return api_request("POST", "/api/issues", {
      project = { id = project_id },
      summary = summary,
      description = description,
    }, instance_config)
  end

  function instance:add_comment(task_id, comment_text)
    return api_request("POST", "/api/issues/" .. task_id .. "/comments", { text = comment_text }, instance_config)
  end

  function instance:get_task_statuses()
    return api_request("GET", "/api/admin/projects/states?fields=id,name", nil, instance_config)
  end

  function instance:update_task_status(task_id, status_id)
    return api_request(
      "POST",
      "/api/issues/" .. task_id .. "/execute",
      { command = "State " .. status_id },
      instance_config
    )
  end

  function instance:search_tasks(query)
    return api_request(
      "GET",
      "/api/issues?fields=id,summary,description,project(name)&query=" .. vim.fn.escape(query, "?&="),
      nil,
      instance_config
    )
  end

  function instance:get_tags()
    return api_request("GET", "/api/issueTags?fields=id,name", nil, instance_config)
  end

  function instance:get_task_tags(task_id)
    local task = api_request("GET", "/api/issues/" .. task_id .. "?fields=tags(name)", nil, instance_config)
    return vim.tbl_map(function(tag)
      return tag.name
    end, task.tags or {})
  end

  function instance:update_task_tags(task_id, tag_name, action)
    local command = action == "add" and "add " or "remove "
    command = command .. "tag " .. tag_name
    return api_request("POST", "/api/issues/" .. task_id .. "/execute", { command = command }, instance_config)
  end

  function instance:log_work_item(task_id, duration)
    return api_request("POST", "/api/issues/" .. task_id .. "/timeTracking/workItems", {
      duration = {
        minutes = math.floor(duration / 60),
      },
      text = "Work logged via Neovim plugin",
    }, instance_config)
  end

  return instance
end

return M
