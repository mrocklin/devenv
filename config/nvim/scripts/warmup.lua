-- Headless warmup: install treesitter parsers + mason LSPs.
-- Called from bootstrap.sh via `nvim --headless -c 'luafile <this>' -c 'qa'`
-- so init.lua has already loaded plugins and run mason.setup().
-- Idempotent: re-running is a no-op once everything's installed.

vim.cmd("TSInstallSync python rust typescript javascript lua vim")

local packages = { "pyright", "typescript-language-server", "rust-analyzer" }
vim.cmd("MasonInstall " .. table.concat(packages, " "))

-- MasonInstall is async; block until each package shows up in the registry.
local registry = require("mason-registry")
local ok = vim.wait(180000, function()
  for _, p in ipairs(packages) do
    if not registry.is_installed(p) then return false end
  end
  return true
end, 500)

if not ok then
  io.stderr:write("warmup: mason install incomplete after 180s\n")
  os.exit(1)
end
