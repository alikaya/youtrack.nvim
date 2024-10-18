local M = {}
local config = require("youtrack.config")

function M.show_task_details(task)
  local popup_width = math.floor(vim.o.columns * 0.4)
  local popup_height = math.floor(vim.o.lines * 0.8)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = popup_width,
    height = popup_height,
    col = vim.o.columns,
    row = 1,
    anchor = "NE",
    style = "minimal",
    border = "rounded",
  })

  -- Görev detaylarını buffer'a yaz
  local lines = {
    "ID: " .. task.id,
    "Summary: " .. task.summary,
    "Status: " .. (task.status and task.status.name or "Unknown"),
    "",
    "Description:",
    task.description or "No description available.",
    "",
    "Comments:",
  }

  if task.comments then
    for _, comment in ipairs(task.comments) do
      table.insert(lines, comment.author.name .. ": " .. comment.text)
      table.insert(lines, "")
    end
  else
    table.insert(lines, "No comments available.")
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Tema renklerini uygula
  vim.api.nvim_buf_add_highlight(buf, -1, config.options.theme.header, 0, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, config.options.theme.task, 1, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, config.options.theme.task, 2, 0, -1)

  -- Buffer'ı salt okunur yap
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -- Kısayol tuşları ekle
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
