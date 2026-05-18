-- Headless warmup: install treesitter parsers + mason LSPs.
-- Called from bootstrap.sh via `nvim --headless -c 'luafile <this>' -c 'qa'`
-- so init.lua has already loaded plugins and run mason.setup().
-- Idempotent: re-running is a no-op once everything's installed.

-- Treesitter: TSInstallSync prompts y/n on already-installed parsers, which
-- spam-loops in headless mode (no stdin). Install only what's missing.
local ts_parsers = require("nvim-treesitter.parsers")
local missing_parsers = vim.tbl_filter(
  function(p) return not ts_parsers.has_parser(p) end,
  { "python", "rust", "typescript", "javascript", "lua", "vim" }
)
if #missing_parsers > 0 then
  vim.cmd("TSInstallSync " .. table.concat(missing_parsers, " "))
end

-- Mason LSPs: MasonInstall re-downloads existing packages, so filter first.
local registry = require("mason-registry")
local missing_packages = vim.tbl_filter(
  function(p) return not registry.is_installed(p) end,
  { "pyright", "typescript-language-server", "rust-analyzer" }
)

if #missing_packages > 0 then
  -- pcall: MasonInstall surfaces npm stderr (e.g. EBADENGINE warnings) as a
  -- vim error even on success. We rely on the registry poll below to verify.
  pcall(vim.cmd, "MasonInstall " .. table.concat(missing_packages, " "))

  local ok = vim.wait(180000, function()
    for _, p in ipairs(missing_packages) do
      if not registry.is_installed(p) then return false end
    end
    return true
  end, 500)

  if not ok then
    io.stderr:write("warmup: mason install incomplete after 180s\n")
    os.exit(1)
  end
end
