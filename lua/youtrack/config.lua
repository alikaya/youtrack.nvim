local M = {}

M.defaults = {
  instances = {
    default = {
      url = "https://youtrack.example.com",
      token = "YOUR_API_TOKEN",
    },
  },
  current_instance = "default",
  log_level = "INFO",
  cache_config = {
    ttl = 300, -- 5 dakika
  },
  auto_open_dashboard = false,
  custom_report_templates = {},
  lsp = {
    enabled = true,
    filetypes = { "lua", "python", "javascript" },
  },
  theme = {
    header = "String",
    task = "Identifier",
    project = "Type",
    tag = "Special",
  },
  keymaps = {
    list_projects = "<leader>yp",
    list_tasks = "<leader>yt",
    list_my_tasks = "<leader>ym",
    create_task = "<leader>yc",
    search_tasks = "<leader>ys",
    show_dashboard = "<leader>yd",
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
