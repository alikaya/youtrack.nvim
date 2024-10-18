local M = {}

local levels = {
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
}

local current_level = levels.INFO

function M.setup(level)
  current_level = levels[level:upper()] or levels.INFO
end

local function log(level, message)
  if levels[level] >= current_level then
    local info = debug.getinfo(3, "Sl")
    local lineinfo = info.short_src .. ":" .. info.currentline
    print(string.format("[YouTrack][%s][%s] %s: %s", os.date("%Y-%m-%d %H:%M:%S"), level, lineinfo, message))
  end
end

function M.debug(message)
  log("DEBUG", message)
end

function M.info(message)
  log("INFO", message)
end

function M.warn(message)
  log("WARN", message)
end

function M.error(message)
  log("ERROR", message)
end

return M

