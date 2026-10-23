-- Minimal LunarVim config for reliability in the Python practice workspace.
-- Keep the surface area small: editor defaults and LSP-safe shims.

-- Follow macOS appearance at startup. Ghostty owns the window background;
-- Nightfly remains the dark theme and TokyoNight Day supplies light highlights.
local interface_style = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
local is_dark = vim.v.shell_error == 0 and vim.trim(interface_style):lower() == "dark"

vim.opt.background = is_dark and "dark" or "light"
vim.opt.termguicolors = true
vim.g.nightflyTransparent = true
vim.g.nightflyNormalFloat = true
vim.g.nightflyNormalPmenu = true
vim.opt.relativenumber = true
vim.opt.number = true
lvim.colorscheme = is_dark and "nightfly" or "tokyonight-day"

if not is_dark then
  lvim.builtin.theme.name = "tokyonight"
  lvim.builtin.theme.tokyonight.options.style = "day"
  lvim.builtin.theme.tokyonight.options.transparent = true
  lvim.builtin.theme.tokyonight.options.styles.sidebars = "transparent"
  lvim.builtin.theme.tokyonight.options.styles.floats = "transparent"
end
lvim.plugins = {
  {
    "bluz71/vim-nightfly-colors",
    name = "nightfly",
    priority = 1000,
    lazy = false,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    config = function()
      require("render-markdown").setup({
        enabled = false,
      })
    end,
  },
}

-- Core editing ergonomics.
vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.linebreak = true
vim.opt.signcolumn = "yes"

-- Avoid background completion work in the editor pane. This was the most likely
-- source of the pane-specific freezing.
if lvim.builtin and lvim.builtin.treesitter then
  pcall(function()
    lvim.builtin.treesitter.highlight.enable = true
  end)
end

-- nvim-tree's macOS filesystem watcher can recurse through an enormous tree
-- when LunarVim is launched from $HOME. Refresh on buffer events instead.
if lvim.builtin and lvim.builtin.nvimtree then
  lvim.builtin.nvimtree.setup.filesystem_watchers.enable = false
end

-- Small utility mapping: find directories from Telescope.
lvim.builtin.which_key.mappings["s"]["d"] = {
  "<cmd>lua require('telescope.builtin').find_files({ find_command = {'fd', '--type', 'd', '--hidden', '--exclude', '.git'} })<cr>",
  "Find Directories",
}

lvim.builtin.which_key.mappings["m"] = {
  name = "Markdown",
  r = { "<cmd>RenderMarkdown buf_toggle<cr>", "Toggle Render" },
  p = { "<cmd>RenderMarkdown preview<cr>", "Side Preview" },
}
lvim.keys.normal_mode["<leader>mr"] = "<cmd>RenderMarkdown buf_toggle<cr>"
lvim.keys.normal_mode["<leader>mp"] = "<cmd>RenderMarkdown preview<cr>"

-- Neovim 0.11 compatibility shims for older LunarVim plugins.
do
  local util = vim.lsp.util
  local make_position_params = util.make_position_params
  util.make_position_params = function(window, position_encoding)
    if position_encoding == nil then
      local bufnr = vim.api.nvim_win_get_buf(window or 0)
      local client = vim.lsp.get_clients({ bufnr = bufnr })[1]
      position_encoding = (client and client.offset_encoding) or "utf-16"
    end
    return make_position_params(window, position_encoding)
  end
end

do
  local make_client_capabilities = vim.lsp.protocol.make_client_capabilities
  vim.lsp.protocol.make_client_capabilities = function()
    local capabilities = make_client_capabilities()
    capabilities.general = capabilities.general or {}
    capabilities.general.positionEncodings = { "utf-16" }
    return capabilities
  end
end

-- Keep ruff from being auto-installed by Mason; it already lives on PATH.
lvim.lsp.installer.setup.automatic_installation.exclude = { "ruff" }

-- Deliberately do not load a second plugin manager or auto-triggered completion
-- layer here. LunarVim already provides the core editor/LSP stack, and keeping
-- this config lean makes it far less fragile.

-- Preserve the language parsers present on the source MacBook.
lvim.builtin.treesitter.ensure_installed = {
  "bash", "c_sharp", "comment", "css", "csv", "gitattributes", "gitignore", "go",
  "html", "ini", "java", "javascript", "json", "jsonc", "lua", "luadoc",
  "markdown", "markdown_inline", "python", "regex", "rust", "toml", "tsx",
  "typescript", "vim", "vimdoc", "xml", "yaml",
}
