local M = {}
local config

function M.setup(opts)
  config = opts or {}
  config.ttl = config.ttl or 300 -- varsayılan 5 dakika
end

local cache = {}

function M.get_or_set(key, fetch_fn)
  if cache[key] and os.time() - cache[key].time < config.ttl then
    return cache[key].value
  end

  local value = fetch_fn()
  cache[key] = { value = value, time = os.time() }
  return value
end

function M.invalidate(key)
  cache[key] = nil
end

function M.clear()
  cache = {}
end

return M
