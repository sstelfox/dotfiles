return {
  -- This would be fine but fails to be sufficiently context aware that it causes more trouble that
  -- its worth. The additions of matching/closing pairs isn't context aware enough that it will
  -- create invalid syntax that needs to be cleaned up. It takes less effort to add one more
  -- character than advance and remove an uneeded character and the latter is significantly more
  -- common with this plugin.
  { "mini.pairs", enabled = false },
}
