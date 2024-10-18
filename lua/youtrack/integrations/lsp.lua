local M = {}
local utils = require("youtrack.utils")
local config = require("youtrack.config")

function M.setup()
  if config.options.lsp.enabled then
    vim.lsp.handlers["textDocument/hover"] = M.enhanced_hover

    -- LSP entegrasyonu için otomatik komut oluştur
    vim.api.nvim_create_autocmd("FileType", {
      pattern = config.options.lsp.filetypes,
      callback = function()
        vim.lsp.buf.add_workspace_folder()
      end,
    })
  end
end

function M.enhanced_hover(err, result, ctx, config)
  local bufnr = ctx.bufnr
  local client = vim.lsp.get_client_by_id(ctx.client_id)

  -- Standart LSP hover işlemini gerçekleştir
  local original_result = vim.lsp.handlers.hover(err, result, ctx, config)

  -- Youtrack görev ID'sini ara
  local line = vim.api.nvim_get_current_line()
  local task_id = line:match("(%w+-%d+)") -- Örnek: YT-1234

  if task_id then
    -- Youtrack'ten görev bilgilerini al
    local current_instance = require("youtrack").instances[require("youtrack.config").options.current_instance]
    local task = current_instance:get_task(task_id)
    if task then
      -- Hover penceresine Youtrack bilgilerini ekle
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      table.insert(lines, "")
      table.insert(lines, "Youtrack Task: " .. task.summary)
      table.insert(lines, "Status: " .. task.status.name)
      table.insert(lines, "Description: " .. (task.description or "No description available"))
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    end
  end

  return original_result
end

function M.go_to_task()
  local line = vim.api.nvim_get_current_line()
  local task_id = line:match("(%w+-%d+)") -- Örnek: YT-1234

  if task_id then
    require("youtrack").show_task_details(task_id)
  else
    utils.notify("No Youtrack task ID found on current line", vim.log.levels.WARN)
  end
end

return M
