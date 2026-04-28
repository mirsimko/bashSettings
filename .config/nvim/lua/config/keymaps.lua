vim.keymap.set({ "n", "v" }, "//", ":TComment<CR>", { silent = true })
vim.keymap.set("n", "<C-D>", ":NERDTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<C-N>", ":nohl<CR>", { silent = true })

vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Terminal: Normal mode" })
vim.keymap.set("n", "<leader>ti", ":startinsert<CR>", { silent = true, desc = "Terminal: Insert mode" })
vim.keymap.set("n", "<CR>", function()
  return vim.bo.buftype == "terminal" and "i" or "<CR>"
end, { expr = true, desc = "Terminal: Insert mode" })

local window_nav = {
  h = "left",
  j = "down",
  k = "up",
  l = "right",
}

for key, direction in pairs(window_nav) do
  vim.keymap.set("n", "<M-" .. key .. ">", "<C-w>" .. key, { desc = "Window: Move " .. direction })
  vim.keymap.set("t", "<M-" .. key .. ">", [[<C-\><C-n><C-w>]] .. key, { desc = "Window: Move " .. direction })
  vim.keymap.set("t", "<C-w>" .. key, [[<C-\><C-n><C-w>]] .. key, { desc = "Window: Move " .. direction })
end

vim.keymap.set("t", "<C-w><C-w>", [[<C-\><C-n><C-w><C-w>]], { desc = "Window: Cycle" })

vim.keymap.set("n", "<leader>cc", function()
  require("codex").toggle()
end, { desc = "Codex: Toggle" })

vim.keymap.set("v", "<leader>cs", function()
  require("codex").actions.send_selection()
end, { desc = "Codex: Send selection" })
