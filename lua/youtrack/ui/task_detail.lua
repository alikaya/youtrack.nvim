local M = {}
local config = require("youtrack.config")

function M.show(task)
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

  local content = {
    "# " .. task.summary,
    "",
    "ID: " .. task.id,
    "Status: " .. (task.status and task.status.name or "Unknown"),
    "Project: " .. (task.project and task.project.name or "Unknown"),
    "",
    "## Description",
    task.description or "No description available.",
    "",
    "## Comments",
  }

  if task.comments and #task.comments > 0 then
    for _, comment in ipairs(task.comments) do
      table.insert(content, "- " .. comment.author.name .. ": " .. comment.text)
    end
  else
    table.insert(content, "No comments available.")
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

  -- Tema renklerini uygula
  vim.api.nvim_buf_add_highlight(buf, -1, config.options.theme.header, 0, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, config.options.theme.task, 2, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, config.options.theme.task, 3, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, config.options.theme.task, 4, 0, -1)

  -- Kısayol tuşları
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", opts)
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "c",
    string.format(":lua require('youtrack').add_comment('%s')<CR>", task.id),
    opts
  )
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "s",
    string.format(":lua require('youtrack').change_task_status('%s')<CR>", task.id),
    opts
  )
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "e",
    string.format(":lua require('youtrack.integrations.markdown').edit_description('%s')<CR>", task.id),
    opts
  )

  -- Kısayol bilgilerini ekle
  vim.api.nvim_buf_set_lines(
    buf,
    -1,
    -1,
    false,
    { "", "Press 'q' to close, 'c' to add a comment, 's' to change status, 'e' to edit description" }
  )
end

return M
