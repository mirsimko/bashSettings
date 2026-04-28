return {
  { "tpope/vim-fugitive" },
  { "Lokaltog/vim-easymotion" },
  { "tpope/vim-rails" },
  { "vim-scripts/The-NERD-tree" },
  { "tpope/vim-surround" },
  { "vim-scripts/vimlatex" },
  { "vim-scripts/OmniCppComplete" },
  {
    "plasticboy/vim-markdown",
    init = function()
      vim.g.vim_markdown_folding_disabled = 1
    end,
  },
  {
    "vim-scripts/Syntastic",
    init = function()
      vim.g.syntastic_cpp_compiler_options = " -std=c++11 -stdlib=libc++"
      vim.g.syntastic_always_populate_loc_list = 1
      vim.g.syntastic_auto_loc_list = 1
      vim.g.syntastic_check_on_wq = 0
      vim.g.syntastic_python_checkers = {
        "flake8 --ignore=E225,E501,E302,E261,E262,E701,E241,E126,E127,E128,W801",
        "python3",
      }
    end,
  },
  { "vim-scripts/tComment" },
  { "vim-scripts/securemodelines" },
  {
    "luochen1990/rainbow",
    init = function()
      vim.g.rainbow_active = 1
    end,
  },
  { "bogado/file-line" },
  { "vim-scripts/grep.vim" },
  { "vim-scripts/Tabular" },
  { "Lokaltog/vim-powerline" },
  {
    "vim-scripts/Solarized",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.solarized_termtrans = 1
      vim.cmd.colorscheme("solarized")
    end,
  },
  { "airblade/vim-gitgutter" },
  { "vim-scripts/ack.vim" },
  { "reedes/vim-pencil" },
  { "tpope/vim-repeat" },
  { "ConradIrwin/vim-bracketed-paste" },
  { "bronson/vim-crosshairs" },
  { "christoomey/vim-tmux-navigator" },
  { "tmhedberg/matchit" },
  { "vim-scripts/a.vim" },
  {
    "rstacruz/sparkup",
    rtp = "vim",
  },
  { "vim-scripts/L9" },
  {
    "vim-scripts/FuzzyFinder",
    dependencies = { "vim-scripts/L9" },
  },
  {
    "kien/ctrlp.vim",
    init = function()
      vim.g.ctrlp_map = "<Leader>t"
      vim.g.ctrlp_cmd = "CtrlP"
      vim.g.ctrlp_match_window_bottom = 0
      vim.g.ctrlp_match_window_reversed = 0
      vim.g.ctrlp_custom_ignore = [[\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py]]
      vim.g.ctrlp_working_path_mode = 0
      vim.g.ctrlp_dotfiles = 0
      vim.g.ctrlp_switch_buffer = 0
    end,
  },
  { "svermeulen/vim-easyclip" },
}
