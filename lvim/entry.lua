-- Neovim 0.11+ compat: vim.tbl_add_reverse_lookup is deprecated (and slated for
-- removal). LunarVim core (lvim.core.log) and pinned plugins still call it, and the
-- first call happens during bootstrap — before user config.lua loads — so the shim
-- must live here, at the entry point, to neutralize it globally before any caller.
-- NOTE: re-apply this block if you ever reinstall/update LunarVim itself.
vim.tbl_add_reverse_lookup = function(tbl)
  for _, k in ipairs(vim.tbl_keys(tbl)) do
    local v = tbl[k]
    if tbl[v] then
      error(string.format(
        "The reverse lookup found an existing value for %q while processing key %q",
        tostring(v), tostring(k)))
    end
    tbl[v] = k
  end
  return tbl
end
vim.tbl_islist = vim.islist   -- deprecated rename -> vim.islist
vim.tbl_isarray = vim.isarray -- deprecated rename -> vim.isarray
vim.lsp.get_active_clients = vim.lsp.get_clients -- deprecated rename -> vim.lsp.get_clients

-- Silence the *echoes* of Neovim-core deprecations emitted from LunarVim's pinned
-- plugins (tbl_flatten, validate, str_utfindex, region, highlight, start_client,
-- for_each_buffer_client, client:supports_method/request, diagnostic.is_disabled...).
-- They come from vendored plugin code that can't be fixed without forking, and the
-- deprecated functions still work — only the interrupting message is noise. Usages
-- are still recorded for ":checkhealth vim.deprecated"; only the echo is suppressed.
do
  local orig_deprecate = vim.deprecate
  vim.deprecate = function(name, alternative, version, plugin, backtrace)
    if plugin == nil or plugin == "Nvim" then
      pcall(function()
        require("vim.deprecated.health").add(name, version, debug.traceback(), alternative)
      end)
      return nil
    end
    return orig_deprecate(name, alternative, version, plugin, backtrace)
  end
end

dofile(assert(vim.env.LUNARVIM_BASE_DIR) .. "/init.lua")
