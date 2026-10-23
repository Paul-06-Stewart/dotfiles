-- Invoked after the locked plugins have been restored.
local parsers = { "bash", "c_sharp", "comment", "css", "csv", "gitattributes", "gitignore", "go", "html", "ini", "java", "javascript", "json", "jsonc", "lua", "luadoc", "markdown", "markdown_inline", "python", "regex", "rust", "toml", "tsx", "typescript", "vim", "vimdoc", "xml", "yaml" }
local missing = {}
for _, name in ipairs(parsers) do
  if not require("nvim-treesitter.parsers").has_parser(name) then table.insert(missing, name) end
end
if #missing > 0 then vim.cmd("TSInstallSync " .. table.concat(missing, " ")) end
local servers = { "bash-language-server", "css-lsp", "gopls", "html-lsp", "json-lsp", "lemminx", "lua-language-server", "powershell-editor-services", "pyright", "tailwindcss-language-server", "terraform-ls", "typescript-language-server", "vale-ls", "vim-language-server", "yaml-language-server", "stylua", "shfmt" }
local registry = require("mason-registry")
local versions = vim.fn.json_decode(vim.fn.readfile(assert(vim.env.DOTFILES_MASON_VERSIONS)))
local failures = {}
local started = false
registry.refresh(function()
  for _, name in ipairs(servers) do
    local package = registry.get_package(name)
    if not package:is_installed() then
      package:once("install:failed", function() failures[name] = true end)
      package:install({ version = versions[name] })
    end
  end
  started = true
end)
local began = vim.uv.now()
local function check()
  if next(failures) or vim.uv.now() - began > 600000 then
    io.stderr:write("Language server setup failed or timed out. Inspect :Mason and rerun ./install.sh.\n")
    vim.cmd("cquit 1")
    return
  end
  local complete = started
  for _, name in ipairs(servers) do
    if not registry.has_package(name) or not registry.get_package(name):is_installed() then complete = false end
  end
  if complete then
    print("Editor tools installed: " .. #parsers .. " parsers, " .. #servers .. " Mason packages")
    vim.cmd("qa")
  else
    vim.defer_fn(check, 500)
  end
end
vim.defer_fn(check, 500)
