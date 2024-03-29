set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"let path = '~/some/path/here'
"call vundle#rc(path)

" let Vundle manage Vundle, required
Plugin 'gmarik/vundle'
Plugin 'gmarik/Vundle.vim'
" 
" The following are examples of different formats supported.
" Keep Plugin commands between here and filetype plugin indent on.
" scripts on GitHub repos
" for git actions from within vim
Plugin 'tpope/vim-fugitive'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'tpope/vim-rails.git'
" file selector
Plugin 'The-NERD-tree'
" surround tool
Plugin 'tpope/vim-surround'
Plugin 'vimlatex'
Plugin 'OmniCppComplete'
" .md tool
Plugin 'plasticboy/vim-markdown'
Plugin 'Syntastic'
Plugin 'tComment'
" disables modelines as they are a potential security breach
Plugin 'securemodelines'
" rainbow parentheses
" Plugin 'rainbow_parentheses.vim'
Plugin 'luochen1990/rainbow'
let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
Plugin 'file-line'
Plugin 'grep.vim'
Plugin 'Tabular'
Plugin 'Lokaltog/vim-powerline'
" color-scheme
Plugin 'Solarized' 
" git changes
Plugin 'airblade/vim-gitgutter'
" a grep-like search tool	
Plugin 'ack.vim'
" vim writing tool for e.g. latex
Plugin 'reedes/vim-pencil'
" better functionality of the '.' command
Plugin 'tpope/vim-repeat'
" automatic delimeters (e.g. brackets, quotes) closing
" Plugin 'Raimondi/delimitMate'
Plugin 'ConradIrwin/vim-bracketed-paste'
Plugin 'bronson/vim-crosshairs'
" moving in tmux as if in vim
Plugin 'christoomey/vim-tmux-navigator'
" C++ and Python automatic code completion
" Plugin 'oblitum/YouCompleteMe'
Plugin 'tmhedberg/matchit'


nnoremap // :TComment<CR>
vnoremap // :TComment<CR>

Plugin 'a.vim'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" scripts from http://vim-scripts.org/vim/scripts.html
Plugin 'L9'
Plugin 'FuzzyFinder'
Plugin 'kien/ctrlp.vim'
" Plugin 'Valloric/YouCompleteMe'
" scripts not on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" ...
" clipping and pasting made faster
Plugin 'svermeulen/vim-easyclip'
call vundle#end()            " required
filetype plugin indent on     " required

" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Plugin commands are not allowed.
" Put your stuff after this line
if &cp | set nocp | endif
nmap \ihn :IHN
nmap \is :IHS:A
nmap \ih :IHS
let s:cpo_save=&cpo
set cpo&vim
nmap gx <Plug>NetrwBrowseX
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
imap \ihn :IHN
imap \is :IHS:A
imap \ih :IHS

let &cpo=s:cpo_save
unlet s:cpo_save

set laststatus=2   " Always show the statusline
set backspace=indent,eol,start
set fileencodings=ucs-bom,utf-8,default,latin1
set helplang=en
set history=50
set hlsearch
set ignorecase
set incsearch
set nomodeline    " security measure ... disables txt modelines
set printoptions=paper:letter
set ruler
set shiftwidth=2
set smartindent
set softtabstop=2
" vim: set ft=vim :
set number
set runtimepath^=~/.vim/bundle/ctrlp.vim
nmap <silent> <C-D> :NERDTreeToggle<CR>

" ctrlP settings
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
:let g:ctrlp_map = '<Leader>t'
:let g:ctrlp_match_window_bottom = 0
:let g:ctrlp_match_window_reversed = 0
:let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
:let g:ctrlp_working_path_mode = 0
:let g:ctrlp_dotfiles = 0
:let g:ctrlp_switch_buffer = 0

" This function will restore the last known position
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`" 
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END 

" Syntatic options
" let g:syntastic_mode_map = { 'mode': 'active',
"   \ 'active_filetypes': [],
"   \ 'passive_filetypes': ['html'] }
" let g:syntastic_check_on_open=1
" let g:syntastic_enable_signs=1
" let g:syntastic_auto_loc_list=1
" 
" function! MakeSession()
"   let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
"   if (filewritable(b:sessiondir) != 2)
"     exe 'silent !mkdir -p ' b:sessiondir
"     redraw!
"   endif
"   let b:filename = b:sessiondir . '/session.vim'
"   exe "mksession! " . b:filename
" endfunction
" 
" function! LoadSession()
"   let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
"   let b:sessionfile = b:sessiondir . "/session.vim"
"   if (filereadable(b:sessionfile))
"     exe 'source ' b:sessionfile
"     else
"     echo "No session loaded."
"   endif
" endfunction
" au VimEnter * nested :call LoadSession()
" au VimLeave * :call MakeSession()
nmap <silent> <C-N> :nohl<CR>
" set mouse=a " this sets the mouse on

"markdown highlight options
let g:vim_markdown_folding_disabled=1
" let g:vim_markdown_math=1 " for latex math

set t_Co=256 " Explicitly tell vim that the terminal supports 256 colors
let g:Powerline_symbols = 'unicode'

autocmd QuickFixCmdPost *grep* cwindow
au FileType python  set tabstop=4 shiftwidth=4 textwidth=140 softtabstop=4

" spell checking for certain file extensions
autocmd BufRead,BufNewFile *.tex,*.txt,*.html,*.yml,*.md setlocal spell
" Add highlighting for function definition in C++
function! EnhanceCppSyntax()
  syn match cppFuncDef "::\~\?\zs\h\w*\ze([^)]*\()\s*\(const\)\?\)\?$"
  hi def link cppFuncDef Special
endfunction
autocmd Syntax cpp call EnhanceCppSyntax()

" C++11 Syntastic support
let g:syntastic_cpp_compiler_options = ' -std=c++11 -stdlib=libc++'
" recommended syntastic options
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers=['flake8 --ignore=E225,E501,E302,E261,E262,E701,E241,E126,E127,E128,W801','python3']

" Comment
let mapleader=','
nnoremap // :TComment<CR>
vnoremap // :TComment<CR>

" Solarized options
syntax enable
let g:solarized_termtrans=1 " transparent background
set background=dark
colorscheme solarized

" this line enables vim-repeat
silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)

" DelimitMate basic functionality
" let delimitMate_expand_cr = 1
" filetype indent plugin on

" crosshairs
set cursorline
" set cursorcolumn

" moving in vim windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

let g:EasyClipUseSubstituteDefaults = 1
