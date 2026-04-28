local function toggle_venn()
  if vim.b.venn_enabled then
    vim.cmd("setlocal virtualedit=")
    vim.cmd("mapclear <buffer>")
    vim.b.venn_enabled = nil
    vim.notify("Venn: off")
    return
  end

  vim.b.venn_enabled = true
  vim.cmd("setlocal virtualedit=all")
  local opts = { buffer = 0, silent = true }
  vim.keymap.set("n", "J", "<C-v>j:VBox<CR>", opts)
  vim.keymap.set("n", "K", "<C-v>k:VBox<CR>", opts)
  vim.keymap.set("n", "L", "<C-v>l:VBox<CR>", opts)
  vim.keymap.set("n", "H", "<C-v>h:VBox<CR>", opts)
  vim.keymap.set("v", "f", ":VBox<CR>", opts)
  vim.notify("Venn: on (HJKL draw, visual+f boxes selection)")
end

return {
  {
    "jbyuki/venn.nvim",
    cmd = { "VBox", "VBoxD", "VBoxDO", "VBoxH", "VBoxHO" },
    keys = {
      { "<leader>vd", toggle_venn, desc = "Venn: Toggle diagram mode" },
    },
  },
}
