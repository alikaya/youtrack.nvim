local M = {}

local queue = {}
local is_processing = false

function M.setup()
  -- Herhangi bir başlangıç konfigürasyonu gerekirse buraya eklenebilir
end

function M.push(job)
  table.insert(queue, job)
  M.process()
end

function M.process()
  if is_processing or #queue == 0 then
    return
  end

  is_processing = true
  local job = table.remove(queue, 1)

  vim.schedule(function()
    local status, result = pcall(job.fn)
    if not status then
      if job.on_error then
        job.on_error(result)
      else
        require("youtrack.log").error("Job failed: " .. job.name .. " - " .. result)
      end
    elseif job.on_success then
      job.on_success(result)
    end

    is_processing = false
    M.process() -- İşlem tamamlandığında bir sonraki işi başlat
  end)
end

return M
