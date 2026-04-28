vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.fileencodings = { "ucs-bom", "utf-8", "default", "latin1" }
vim.opt.helplang = "en"
vim.opt.history = 50
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.laststatus = 2
vim.opt.modeline = false
vim.opt.number = true
if vim.fn.exists("&printoptions") == 1 then
  vim.opt.printoptions = "paper:letter"
end
vim.opt.ruler = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.softtabstop = 2
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.background = "dark"
vim.opt.wildignore:append({ "*/tmp/*", "*.so", "*.swp", "*.zip" })

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = "*grep*",
  command = "cwindow",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.textwidth = 140
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.tex", "*.txt", "*.html", "*.yml", "*.md" },
  command = "setlocal spell",
})

vim.api.nvim_create_autocmd("Syntax", {
  pattern = "cpp",
  callback = function()
    vim.cmd([[syntax match cppFuncDef "::\~\?\zs\h\w*\ze([^)]*\()\s*\(const\)\?\)\?$"]])
    vim.cmd("highlight default link cppFuncDef Special")
  end,
})
