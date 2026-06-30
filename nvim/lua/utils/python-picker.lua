---@class utils.python-picker
local M = {}

-- Get Python version info
local function get_python_version(python_path)
  local result = vim.fn.system({ python_path, "--version" })
  if vim.v.shell_error == 0 and result then
    return result:match("Python%s+([%d%.]+)") or "unknown"
  end
  return "unknown"
end

-- Get virtual environment name from path
local function get_venv_name(python_path)
  local venv_path = vim.fn.fnamemodify(python_path, ":h:h")
  return vim.fn.fnamemodify(venv_path, ":t")
end

local function parse_pyvenv_cfg(python_path)
  local venv_path = vim.fn.fnamemodify(python_path, ":h:h")
  local cfg_path = venv_path .. "/pyvenv.cfg"

  if vim.fn.filereadable(cfg_path) ~= 1 then
    return nil
  end

  local cfg = {}
  local file = io.open(cfg_path, "r")
  if not file then
    return nil
  end

  for line in file:lines() do
    local key, value = line:match("^([^=]+)%s*=%s*(.+)$")
    if key and value then
      cfg[key:gsub("%s+$", "")] = value:gsub("^%s+", "")
    end
  end
  file:close()

  return cfg
end

-- Detect environment type from Python path
local function detect_env_type(python_path)
  local path_lower = python_path:lower()

  if path_lower:match("conda") or path_lower:match("anaconda") or path_lower:match("miniconda") then
    return "conda"
  end

  local venv_path = vim.fn.fnamemodify(python_path, ":h:h")
  if vim.fn.isdirectory(venv_path .. "/conda-meta") == 1 then
    return "conda"
  end

  local cfg = parse_pyvenv_cfg(python_path)
  if cfg and cfg.uv then
    return "uv"
  end
  if cfg then
    local venv_parent = vim.fn.fnamemodify(venv_path, ":h")
    if vim.fn.filereadable(venv_parent .. "/uv.lock") == 1 then
      return "uv"
    end
    return "venv"
  end

  if path_lower:match("pyenv") then
    return "pyenv"
  end

  if
    path_lower:match("/usr/bin")
    or path_lower:match("/usr/local")
    or path_lower:match("/opt/")
    or path_lower:match("/system/")
  then
    return "system"
  end

  return "unknown"
end

-- Get environment icons
local function get_env_icon(env_type)
  local icons = {
    conda = "🐍",
    pyenv = "🔧",
    uv = "⚡",
    venv = "🔵",
    system = "🖥️",
    unknown = "❓",
  }
  return icons[env_type] or icons.unknown
end

-- Check if path is in a virtual environment
local function is_venv(env_type)
  local venv_types = { "conda", "pyenv", "uv", "venv" }
  return vim.tbl_contains(venv_types, env_type)
end

-- Check if debugpy is installed in the given Python environment
local function is_debugpy_installed(python_path)
  vim.fn.system({ python_path, "-c", "import debugpy" })
  return vim.v.shell_error == 0
end

local function is_uv_project()
  local cwd = vim.fn.getcwd()
  if vim.fn.filereadable(cwd .. "/uv.lock") == 1 then
    return true
  end
  local pyproject = cwd .. "/pyproject.toml"
  if vim.fn.filereadable(pyproject) == 1 then
    local file = io.open(pyproject, "r")
    if file then
      local content = file:read("*a")
      file:close()
      if content:match("%[tool%.uv") or content:match('%[build%-system%].-requires.-=.-"hatchling"') then
        return true
      end
    end
  end
  return false
end

-- Install debugpy in the given Python environment
local function install_debugpy(python_path, env_type, callback)
  local install_cmd
  local use_uv = env_type == "uv" or is_uv_project()

  if use_uv and vim.fn.executable("uv") == 1 then
    install_cmd = { "uv", "pip", "install", "--python", python_path, "debugpy" }
  else
    install_cmd = { python_path, "-m", "pip", "install", "debugpy" }
  end

  vim.notify("Installing debugpy...", vim.log.levels.INFO)

  local stderr_lines = {}
  vim.fn.jobstart(install_cmd, {
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if exit_code == 0 then
          vim.notify("debugpy installed successfully", vim.log.levels.INFO)
          if callback then
            callback(true)
          end
        else
          local msg = "Failed to install debugpy"
          if #stderr_lines > 0 then
            msg = msg .. "\n" .. table.concat(stderr_lines, "\n")
          end
          vim.notify(msg, vim.log.levels.ERROR)
          if callback then
            callback(false)
          end
        end
      end)
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stderr_lines, line)
          end
        end
      end
    end,
  })
end

-- Find Python interpreters in various locations
function M.find_python_interpreters()
  local pythons = {}
  local seen = {}

  -- Helper to add Python if not already seen
  local function add_python(path, source, extra_info)
    if path and vim.fn.executable(path) == 1 then
      local real_path = vim.fn.resolve(path)
      if not seen[real_path] then
        seen[real_path] = true
        local version = get_python_version(path)
        local env_type = detect_env_type(path)
        local is_virtual = is_venv(env_type)
        local venv_name = ""

        -- Get environment name based on type
        if is_virtual then
          if env_type == "conda" and path:match("envs") then
            -- Extract conda env name from path like /miniconda3/envs/myenv/bin/python
            local env_match = path:match("envs/([^/]+)/bin")
            venv_name = env_match and (" [" .. env_match .. "]") or ""
          else
            venv_name = " [" .. get_venv_name(path) .. "]"
          end
        end

        -- Get icon for environment type
        local icon = get_env_icon(env_type)

        -- Create display string with icon
        local display = string.format("%s %s%s (v%s, %s)%s", icon, path, venv_name, version, env_type, extra_info or "")

        table.insert(pythons, {
          path = path,
          display = display,
          source = source,
          env_type = env_type,
          version = version,
          is_venv = is_virtual,
          venv_name = is_virtual and (venv_name:match("%[(.+)%]") or get_venv_name(path)) or nil,
          icon = icon,
        })
      end
    end
  end

  -- Get workspace root
  local workspace = vim.fn.getcwd()

  -- 1. Search for workspace virtual environments
  local workspace_patterns = {
    workspace .. "/.venv/bin/python*",
    workspace .. "/venv/bin/python*",
    workspace .. "/env/bin/python*",
    workspace .. "/*venv*/bin/python*",
    workspace .. "/.*/bin/python*",
  }

  for _, pattern in ipairs(workspace_patterns) do
    local matches = vim.fn.glob(pattern, false, true)
    for _, match in ipairs(matches) do
      if match:match("python3") or not match:match("python%d") then
        local env_type = detect_env_type(match)
        add_python(match, env_type == "uv" and "uv" or "workspace")
      end
    end
  end

  -- 2. Search for Conda environments
  if vim.fn.executable("conda") == 1 then
    local result = vim.fn.system({ "conda", "info", "--base" })
    if vim.v.shell_error == 0 and result then
      local conda_base = vim.trim(result)
      if conda_base ~= "" and vim.fn.isdirectory(conda_base) == 1 then
        local conda_envs = conda_base .. "/envs/*/bin/python*"
        local matches = vim.fn.glob(conda_envs, false, true)
        for _, match in ipairs(matches) do
          if match:match("python3") or not match:match("python%d") then
            add_python(match, "conda")
          end
        end
        local conda_python = conda_base .. "/bin/python3"
        add_python(conda_python, "conda", " (base)")
      end
    end
  end

  -- 3. Search for pyenv environments
  local pyenv_root = os.getenv("PYENV_ROOT") or vim.fn.expand("~/.pyenv")
  if vim.fn.isdirectory(pyenv_root) == 1 then
    local pyenv_versions = pyenv_root .. "/versions/*/bin/python*"
    local matches = vim.fn.glob(pyenv_versions, false, true)
    for _, match in ipairs(matches) do
      if match:match("python3") or not match:match("python%d") then
        add_python(match, "pyenv")
      end
    end
  end

  -- 5. Search for UV environments (global)
  local uv_cache = vim.fn.expand("~/.local/share/uv/python/*/bin/python*")
  local uv_matches = vim.fn.glob(uv_cache, false, true)
  for _, match in ipairs(uv_matches) do
    if match:match("python3") or not match:match("python%d") then
      add_python(match, "uv")
    end
  end

  -- 6. Search system PATH
  local path_pythons = {
    vim.fn.exepath("python3"),
    vim.fn.exepath("python"),
  }

  for _, python in ipairs(path_pythons) do
    if python ~= "" then
      add_python(python, "system")
    end
  end

  -- 7. Common system locations
  local system_locations = {
    "/usr/bin/python3",
    "/usr/local/bin/python3",
    "/opt/homebrew/bin/python3",
  }

  for _, location in ipairs(system_locations) do
    add_python(location, "system")
  end

  -- Sort by priority: workspace/uv first, then modern tools, then legacy, then system
  table.sort(pythons, function(a, b)
    local priority = {
      workspace = 1,
      uv = 2,
      conda = 3,
      pyenv = 4,
      venv = 5,
      system = 6,
      unknown = 7,
    }
    local a_priority = priority[a.source] or 999
    local b_priority = priority[b.source] or 999

    -- If same priority, sort by version (newer first)
    if a_priority == b_priority then
      local a_version = a.version or "0"
      local b_version = b.version or "0"
      return a_version > b_version
    end

    return a_priority < b_priority
  end)

  return pythons
end

-- Open picker to select Python interpreter
function M.pick_python(callback)
  local pythons = M.find_python_interpreters()

  if #pythons == 0 then
    vim.notify("No Python interpreters found", vim.log.levels.WARN)
    return
  end

  local displays = {}
  local path_map = {}

  for _, python in ipairs(pythons) do
    table.insert(displays, python.display)
    path_map[python.display] = python.path
  end

  table.insert(displays, "[ Manual input ... ]")

  vim.ui.select(displays, {
    prompt = "Select Python Interpreter:",
  }, function(choice)
    if not choice then
      return
    end

    if choice == "[ Manual input ... ]" then
      vim.ui.input({
        prompt = "Enter Python path:",
        default = vim.fn.exepath("python3"),
      }, function(manual_path)
        if manual_path and manual_path ~= "" then
          if vim.fn.executable(manual_path) == 1 then
            callback(manual_path)
          else
            vim.notify("Invalid Python path: " .. manual_path, vim.log.levels.ERROR)
          end
        end
      end)
    elseif path_map[choice] and callback then
      callback(path_map[choice])
    end
  end)
end

-- Configure Python path for LSP servers
function M.configure_python_lsp(python_path)
  if not python_path or python_path == "" then
    return
  end

  -- Get interpreter info
  local python_info = nil
  for _, interp in ipairs(M.find_python_interpreters()) do
    if interp.path == python_path then
      python_info = interp
      break
    end
  end

  -- Use detected environment info if available, otherwise detect from path
  local env_type = "system"
  local env_name = "system"
  local venv_path = vim.fn.fnamemodify(python_path, ":h:h")

  if python_info then
    env_type = python_info.env_type or detect_env_type(python_path)
    env_name = python_info.venv_name or env_type

    -- Special handling for different environment types
    if env_type == "conda" and env_name then
      -- Keep conda environment name as-is
    elseif env_type == "system" then
      env_name = "system"
    elseif not env_name or env_name == "" then
      env_name = get_venv_name(python_path)
    end
  else
    -- Fallback to path-based detection
    env_type = detect_env_type(python_path)
    if env_type ~= "system" then
      env_name = get_venv_name(python_path)
    end
  end

  -- Set global environment variables
  if env_type == "conda" then
    vim.fn.setenv("CONDA_PREFIX", venv_path)
    vim.fn.setenv("VIRTUAL_ENV", nil)
  elseif env_type ~= "system" then
    vim.fn.setenv("VIRTUAL_ENV", venv_path)
    vim.fn.setenv("CONDA_PREFIX", nil)
  else
    vim.fn.setenv("VIRTUAL_ENV", nil)
    vim.fn.setenv("CONDA_PREFIX", nil)
  end

  -- Store current python info for other tools
  vim.g.python_env = {
    path = python_path,
    venv_path = venv_path,
    env_type = env_type,
    env_name = env_name,
    version = python_info and python_info.version or "unknown",
  }

  -- Configure all running Python LSP clients
  local python_lsp_clients = {}
  local python_lsp_names = { "basedpyright", "pyright", "pylsp", "ruff" }

  for _, client in pairs(vim.lsp.get_clients()) do
    -- Check by name first
    local is_python_lsp = vim.tbl_contains(python_lsp_names, client.name)

    -- Check by filetypes if not found by name
    if not is_python_lsp then
      local filetypes = vim.tbl_get(client, "config", "filetypes") or {}
      if type(filetypes) == "table" and vim.tbl_contains(filetypes, "python") then
        is_python_lsp = true
      end
    end

    if is_python_lsp then
      table.insert(python_lsp_clients, client)
    end
  end

  if #python_lsp_clients == 0 then
    vim.notify("No Python LSP servers running. Open a Python file first.", vim.log.levels.WARN)
    return
  end

  -- Configure each Python LSP client with appropriate settings
  for _, client in pairs(python_lsp_clients) do
    local new_settings = {}
    local new_cmd_env = {}

    -- Configure based on LSP server type
    if client.name == "basedpyright" or client.name == "pyright" then
      new_settings.python = {
        pythonPath = python_path,
      }
      if env_type ~= "system" then
        new_settings.python.venv = env_name
        new_settings.python.venvPath = vim.fn.fnamemodify(venv_path, ":h")
      end
    elseif client.name == "pylsp" then
      new_settings.pylsp = {
        plugins = {
          jedi = {
            environment = python_path,
          },
        },
      }
    end

    -- Set environment variables for LSP process
    if env_type == "conda" then
      new_cmd_env.CONDA_PREFIX = venv_path
    elseif env_type ~= "system" then
      new_cmd_env.VIRTUAL_ENV = venv_path
      new_cmd_env.PATH = venv_path .. "/bin:" .. (vim.fn.getenv("PATH") or "")
    end

    -- Update client configuration
    local new_config = {
      settings = new_settings,
      cmd_env = vim.tbl_extend("force", client.config.cmd_env or {}, new_cmd_env),
    }

    vim.lsp.config(client.name, new_config)

    client:stop()
    vim.defer_fn(function()
      vim.lsp.enable(client.name)
    end, 1000)
  end

  -- Set Neovim Python provider
  vim.g.python3_host_prog = python_path

  -- Notify user
  local version_info = python_info and (" v" .. python_info.version) or ""
  vim.notify(
    string.format(
      "Python Environment: %s [%s]%s\nConfigured %d LSP server(s)",
      env_name,
      env_type,
      version_info,
      #python_lsp_clients
    ),
    vim.log.levels.INFO
  )
end

-- Configure Python path for dap-python
function M.configure_dap_python()
  M.pick_python(function(python_path)
    -- Store the selected path
    vim.g.python_dap_path = python_path

    -- Configure LSP servers with the new python path
    M.configure_python_lsp(python_path)

    -- Also set for Neovim provider
    vim.g.python3_host_prog = python_path

    -- Helper to setup dap-python
    local function setup_dap()
      local ok, dap_python = pcall(require, "dap-python")
      if ok then
        dap_python.setup(python_path)
        vim.notify("Python debugger configured: " .. python_path, vim.log.levels.INFO)
      else
        vim.notify("Python path set: " .. python_path .. " (dap-python not loaded yet)", vim.log.levels.WARN)
      end
    end

    -- Check if debugpy is installed
    if is_debugpy_installed(python_path) then
      setup_dap()
    else
      local env_type = detect_env_type(python_path)
      vim.notify("debugpy not found, installing...", vim.log.levels.WARN)
      install_debugpy(python_path, env_type, function(success)
        if success then
          setup_dap()
        end
      end)
    end
  end)
end

-- Configure only LSP (separate function for LSP-only configuration)
function M.configure_lsp_only()
  M.pick_python(function(python_path)
    M.configure_python_lsp(python_path)
    vim.g.python3_host_prog = python_path
  end)
end

-- Show current Python environment info
function M.show_current_env()
  local env_info = vim.g.python_env
  if not env_info then
    vim.notify("No Python environment configured", vim.log.levels.WARN)
    return
  end

  local info_text = string.format(
    [[
Current Python Environment:
  Name: %s
  Type: %s
  Version: %s
  Path: %s
  Venv: %s
]],
    env_info.env_name or "unknown",
    env_info.env_type or "unknown",
    env_info.version or "unknown",
    env_info.path or "unknown",
    env_info.venv_path or "none"
  )

  vim.notify(info_text, vim.log.levels.INFO)
end

-- Auto-detect and set best Python environment for current project
function M.auto_configure()
  local pythons = M.find_python_interpreters()

  if #pythons == 0 then
    vim.notify("No Python interpreters found", vim.log.levels.WARN)
    return
  end

  -- Priority: workspace venv > uv > conda > system
  local best_python = pythons[1] -- Already sorted by priority

  vim.notify(string.format("Auto-selected: %s", best_python.display), vim.log.levels.INFO)

  M.configure_python_lsp(best_python.path)
  vim.g.python_dap_path = best_python.path

  -- Helper to setup dap-python
  local function setup_dap()
    local ok, dap_python = pcall(require, "dap-python")
    if ok then
      dap_python.setup(best_python.path)
    end
  end

  -- Check and install debugpy if needed
  if is_debugpy_installed(best_python.path) then
    setup_dap()
  else
    install_debugpy(best_python.path, best_python.env_type, function(success)
      if success then
        setup_dap()
      end
    end)
  end
end

-- Quick switch between environments (for statusline integration)
function M.get_current_env_short()
  local env_info = vim.g.python_env
  if not env_info then
    return "No Python"
  end

  local env_display = env_info.env_name or "unknown"
  if env_info.version then
    env_display = env_display .. " (v" .. env_info.version .. ")"
  end

  return env_display
end

-- Create user commands
vim.api.nvim_create_user_command("PythonSelect", function()
  M.configure_lsp_only()
end, { desc = "Select Python environment for LSP" })

vim.api.nvim_create_user_command("PythonSelectDebug", function()
  M.configure_dap_python()
end, { desc = "Select Python environment for debugging and LSP" })

vim.api.nvim_create_user_command("PythonInfo", function()
  M.show_current_env()
end, { desc = "Show current Python environment info" })

vim.api.nvim_create_user_command("PythonAuto", function()
  M.auto_configure()
end, { desc = "Auto-detect and set best Python environment" })

return M
