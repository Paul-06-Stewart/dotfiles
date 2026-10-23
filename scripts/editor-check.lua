local ok, err = pcall(function()
  assert(vim.version().major == 0 and vim.version().minor == 11 and vim.version().patch == 5, "Expected Neovim 0.11.5")
  assert(lvim.colorscheme == "nightfly" or lvim.colorscheme == "tokyonight-day")
  assert(lvim.builtin.nvimtree.setup.filesystem_watchers.enable == false)
  require("telescope").load_extension("fzf")
  local parsers = lvim.builtin.treesitter.ensure_installed
  assert(#parsers == 28, "Expected the captured parser list")
  for _, name in ipairs(parsers) do
    assert(require("nvim-treesitter.parsers").has_parser(name), "Missing parser: " .. name)
  end
  local registry = require("mason-registry")
  local count = 0
  for _, package in ipairs(registry.get_installed_packages()) do count = count + 1 end
  assert(count >= 17, "Missing Mason packages")
  print("LunarVim ready: " .. lvim.colorscheme .. ", 28 parsers, " .. count .. " Mason packages, native fzf loaded")
end)
if not ok then
  io.stderr:write(tostring(err) .. "\n")
  vim.cmd("cquit 1")
end
