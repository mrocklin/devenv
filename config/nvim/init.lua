-- Modern Neovim Configuration
-- Migrated from classic .vimrc

--[[
============================================================================
=> Bootstrap lazy.nvim plugin manager
============================================================================
--]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--[[
============================================================================
=> General Settings (migrated from .vimrc)
============================================================================
--]]
-- Leader key (kept as comma)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- History
vim.opt.history = 1000  -- Increased from 300

-- File handling
vim.opt.autoread = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- UI
vim.opt.number = true          -- Show line numbers (modern addition)
vim.opt.relativenumber = false
vim.opt.scrolloff = 7
vim.opt.wildmenu = true
vim.opt.ruler = true
vim.opt.cmdheight = 2
vim.opt.hidden = true
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.laststatus = 2  -- Always show statusline

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true  -- Override ignorecase if uppercase present
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Indentation (your preferences)
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.textwidth = 79

-- Visual
vim.opt.termguicolors = true  -- Better colors
vim.opt.signcolumn = "yes"    -- Always show sign column (prevents text shift)

-- Encoding
vim.opt.encoding = "utf-8"
vim.opt.fileformats = "unix,dos,mac"

-- No bells
vim.opt.errorbells = false
vim.opt.visualbell = false

-- Better completion
vim.opt.completeopt = "menu,menuone,noselect"

-- Use system clipboard (makes yank/paste work with Cmd+C/Cmd+V)
vim.opt.clipboard = "unnamedplus"

-- Enable filetype detection
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

--[[
============================================================================
=> Plugins
============================================================================
--]]
require("lazy").setup({
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",  -- new main branch dropped the configs module API
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "python", "rust", "typescript", "javascript", "lua", "vim" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Telescope - modern fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
      })
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Comment.nvim - better commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- File explorer (optional, you used buffers/fuzzy finding)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
      })
    end,
  },

  -- Colorscheme - Kanagawa with pure black background
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = false },
        functionStyle = {},
        keywordStyle = { italic = false },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,
        dimInactive = false,
        terminalColors = true,
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = "#000000",
                bg = "#000000",
              },
            },
          },
        },
        overrides = function(colors)
          local theme = colors.theme
          return {
            -- Pure black backgrounds everywhere
            Normal = { bg = "#000000", fg = "#ffffff" },
            NormalFloat = { bg = "#000000", fg = "#ffffff" },
            FloatBorder = { bg = "#000000", fg = "#888888" },
            SignColumn = { bg = "#000000" },
            LineNr = { fg = "#555555", bg = "#000000" },
            CursorLineNr = { fg = "#ffffff", bg = "#000000" },
            StatusLine = { bg = "#000000", fg = "#ffffff" },
            StatusLineNC = { bg = "#000000", fg = "#888888" },
            TabLine = { bg = "#000000", fg = "#888888" },
            TabLineFill = { bg = "#000000" },
            TabLineSel = { bg = "#000000", fg = "#ffffff" },
            Pmenu = { bg = "#000000", fg = "#ffffff" },
            PmenuSel = { bg = "#333333", fg = "#ffffff" },
            PmenuSbar = { bg = "#000000" },
            PmenuThumb = { bg = "#555555" },

            -- Markdown - white body text, bright headers
            ["@markup.heading"] = { fg = "#ffa066", bold = true },
            ["@markup.heading.1.markdown"] = { fg = "#ffa066", bold = true },
            ["@markup.heading.2.markdown"] = { fg = "#ffa066", bold = true },
            ["@markup.heading.3.markdown"] = { fg = "#ffa066", bold = true },
            ["@markup.list"] = { fg = "#ffffff" },
            ["@markup.list.markdown"] = { fg = "#ffffff" },
            ["@text.literal"] = { fg = "#98bb6c" },
            ["@text.uri"] = { fg = "#7fb4ca", underline = true },
            ["@text.emphasis"] = { fg = "#ffffff", italic = true },
            ["@text.strong"] = { fg = "#ffffff", bold = true },

            -- Code syntax - keep readable but not overwhelming
            Identifier = { fg = "#ffffff" },
            Operator = { fg = "#ffffff" },
            Comment = { fg = "#666666" },
          }
        end,
        theme = "wave",
        background = {
          dark = "wave",
          light = "lotus"
        },
      })
      vim.cmd([[colorscheme kanagawa]])
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local custom_theme = require("lualine.themes.auto")

      -- Mute the backgrounds - dark but visible
      local muted_bg = "#1a1a1a"  -- Very dark gray instead of bright colors
      local normal_fg = "#ffffff"
      local inactive_fg = "#888888"

      if custom_theme.normal then
        custom_theme.normal.a = { bg = muted_bg, fg = normal_fg, gui = "bold" }
        custom_theme.normal.b = { bg = "#0a0a0a", fg = normal_fg }
        custom_theme.normal.c = { bg = "#000000", fg = normal_fg }
      end

      if custom_theme.insert then
        custom_theme.insert.a = { bg = muted_bg, fg = normal_fg, gui = "bold" }
      end

      if custom_theme.visual then
        custom_theme.visual.a = { bg = muted_bg, fg = normal_fg, gui = "bold" }
      end

      if custom_theme.replace then
        custom_theme.replace.a = { bg = muted_bg, fg = normal_fg, gui = "bold" }
      end

      if custom_theme.command then
        custom_theme.command.a = { bg = muted_bg, fg = normal_fg, gui = "bold" }
      end

      if custom_theme.inactive then
        custom_theme.inactive.a = { bg = "#000000", fg = inactive_fg }
        custom_theme.inactive.b = { bg = "#000000", fg = inactive_fg }
        custom_theme.inactive.c = { bg = "#000000", fg = inactive_fg }
      end

      require("lualine").setup({
        options = {
          theme = custom_theme,
          component_separators = "|",
          section_separators = "",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "filetype" },  -- Removed encoding and fileformat
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },

  -- Surround (you had this plugin before)
  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  -- Render markdown beautifully in the buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    config = function()
      -- Define custom highlight groups for render-markdown
      vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "#1a1a1a" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = "#141414" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { bg = "#0e0e0e" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { bg = "#0a0a0a" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { bg = "#050505" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { bg = "#000000" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = "#ffa066", bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH2", { fg = "#ffa066", bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH3", { fg = "#ffa066", bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH4", { fg = "#ff8844", bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH5", { fg = "#ff8844", bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH6", { fg = "#ff8844", bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#1a1a1a" })
      vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { fg = "#98bb6c" })
      vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { fg = "#ffffff" })
      vim.api.nvim_set_hl(0, "RenderMarkdownQuote", { fg = "#888888" })
      vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = "#7fb4ca", underline = true })

      require("render-markdown").setup({
        heading = {
          enabled = true,
          sign = false,
          icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
          backgrounds = {
            "RenderMarkdownH1Bg",
            "RenderMarkdownH2Bg",
            "RenderMarkdownH3Bg",
            "RenderMarkdownH4Bg",
            "RenderMarkdownH5Bg",
            "RenderMarkdownH6Bg",
          },
          foregrounds = {
            "RenderMarkdownH1",
            "RenderMarkdownH2",
            "RenderMarkdownH3",
            "RenderMarkdownH4",
            "RenderMarkdownH5",
            "RenderMarkdownH6",
          },
        },
        code = {
          enabled = true,
          sign = false,
          style = "normal",
          left_pad = 2,
          right_pad = 2,
          width = "block",
          border = "thin",
          above = "▄",
          below = "▀",
          highlight = "RenderMarkdownCode",
        },
        bullet = {
          enabled = true,
          icons = { "•", "◦", "▪", "▫" },
          highlight = "RenderMarkdownBullet",
        },
        checkbox = {
          enabled = true,
          unchecked = { icon = "☐ " },
          checked = { icon = "☑ " },
        },
        quote = {
          enabled = true,
          icon = "▎",
          highlight = "RenderMarkdownQuote",
        },
        pipe_table = {
          enabled = true,
          style = "normal",
          cell = "padded",
        },
        win_options = {
          conceallevel = { default = 2, rendered = 2 },
          concealcursor = { default = "", rendered = "" },
        },
      })
    end,
  },
})

--[[
============================================================================
=> LSP Configuration
============================================================================
--]]
-- Setup Mason for LSP server management
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "rust_analyzer", "ts_ls" },
  automatic_installation = true,
})

-- Setup completion
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- LSP keybindings
local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
end

-- Configure language servers using modern vim.lsp.config API
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Python (pyright)
vim.lsp.config.pyright = {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
  capabilities = capabilities,
  on_attach = on_attach,
}

-- Rust (rust-analyzer)
vim.lsp.config.rust_analyzer = {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git" },
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
    },
  },
  on_attach = on_attach,
}

-- TypeScript/JavaScript (ts_ls)
vim.lsp.config.ts_ls = {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  capabilities = capabilities,
  on_attach = on_attach,
}

-- Enable LSP servers
vim.lsp.enable({ "pyright", "rust_analyzer", "ts_ls" })

--[[
============================================================================
=> Keybindings (migrated and modernized from .vimrc)
============================================================================
--]]
local keymap = vim.keymap.set

-- Fast saving
keymap("n", "<leader>w", ":w!<CR>")

-- Clear search highlighting
keymap("n", "<leader><CR>", ":noh<CR>", { silent = true })

-- Window navigation (kept your mappings)
keymap("n", "<C-j>", "<C-W>j")
keymap("n", "<C-k>", "<C-W>k")
keymap("n", "<C-h>", "<C-W>h")
keymap("n", "<C-l>", "<C-W>l")

-- Buffer navigation (modernized)
keymap("n", "<right>", ":bnext<CR>")
keymap("n", "<left>", ":bprevious<CR>")
keymap("n", "<leader>bd", ":bdelete<CR>")

-- Tab navigation (kept your mappings)
keymap("n", "<leader>tn", ":tabnew<CR>")
keymap("n", "<leader>tc", ":tabclose<CR>")

-- Telescope fuzzy finding (replaces old fuzzyfinder)
keymap("n", "<leader>t", "<cmd>Telescope find_files<CR>")
keymap("n", "<leader>g", "<cmd>Telescope live_grep<CR>")
keymap("n", "<leader>b", "<cmd>Telescope buffers<CR>")
keymap("n", "<leader>h", "<cmd>Telescope help_tags<CR>")

-- File explorer
keymap("n", "<leader>e", ":NvimTreeToggle<CR>")

-- Move to beginning of line (your mapping)
keymap("n", "0", "^")

-- Spell checking
keymap("n", "<leader>ss", ":setlocal spell!<CR>")
keymap("n", "<leader>sn", "]s")
keymap("n", "<leader>sp", "[s")
keymap("n", "<leader>sa", "zg")
keymap("n", "<leader>s?", "z=")

-- Markdown rendering toggle
keymap("n", "<leader>m", ":RenderMarkdown toggle<CR>", { silent = true })

-- Quick buffer (scratch)
keymap("n", "<leader>q", ":e ~/buffer<CR>")

-- Visual mode: stay in indent mode
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

--[[
============================================================================
=> Autocommands (migrated from .vimrc)
============================================================================
--]]
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Delete trailing whitespace on save
local trim_whitespace = augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = trim_whitespace,
  pattern = { "*.py", "*.rs", "*.ts", "*.js", "*.html", "*.css", "*.yaml", "*.yml", "*.md", "*.rst", "*.tex", "*.c", "*.h" },
  command = [[%s/\s\+$//e]],
})

-- Language-specific settings
autocmd("FileType", {
  pattern = { "yaml", "yml", "html", "css", "typescript", "javascript" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

-- Python-specific
autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.cindent = false
  end,
})

-- Auto-reload files when they change on disk
local autoread_group = augroup("AutoReload", { clear = true })
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = autoread_group,
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Optional: notify when files are reloaded
autocmd("FileChangedShellPost", {
  group = autoread_group,
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})


-- Disable autocomplete in markdown (and other prose) files - it's distracting
-- when it just suggests dictionary words.
cmp.setup.filetype({ "markdown", "text", "gitcommit" }, {
  enabled = false,
})


--[[
============================================================================
=> Notes
============================================================================
--]]
-- First time setup:
-- 1. Open Neovim, plugins will auto-install
-- 2. Run :Mason to see LSP server installation
-- 3. TSUpdate will install Treesitter parsers
--
-- Key differences from your old .vimrc:
-- - Using Telescope instead of fuzzyfinder (<leader>t for files, <leader>g for grep)
-- - LSP provides go-to-definition (gd), references (gr), hover (K)
-- - Native LSP replaces old omnicomplete
-- - Treesitter provides much better syntax highlighting
-- - Removed old plugins: minibufexpl, bufexplorer, yankring (native features better)
--
-- New useful commands:
-- - gd: Go to definition (LSP)
-- - gr: Find references (LSP)
-- - K: Hover documentation (LSP)
-- - <leader>rn: Rename symbol (LSP)
-- - <leader>ca: Code actions (LSP)
-- - <leader>f: Format code (LSP)
-- - <leader>e: Toggle file explorer
