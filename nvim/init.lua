-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Nightfly with transparent background
vim.g.nightflyTransparent = true

require("lazy").setup({
  {
    "bluz71/vim-nightfly-colors",
    name = "nightfly",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme nightfly")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    commit = "310f0925ec64c7e54f3ee952679d285b13e5a735",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "python", "lua", "javascript", "typescript", "html", "css", "json", "yaml", "bash", "markdown" },
        highlight = { enable = true },
      })
    end,
  },
})
