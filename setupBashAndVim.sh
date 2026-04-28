#!/bin/bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
editor="vim"

usage() {
  cat <<'EOF'
Usage: ./setupBashAndVim.sh [--editor vim|nvim|both] [--vim|--nvim|--both]

Links shell config and installs editor config from this repository.

Examples:
  ./setupBashAndVim.sh
  ./setupBashAndVim.sh --editor nvim
  ./setupBashAndVim.sh --both
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --editor)
      editor="${2:-}"
      shift 2
      ;;
    --vim)
      editor="vim"
      shift
      ;;
    --nvim|--neovim)
      editor="nvim"
      shift
      ;;
    --both)
      editor="both"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$editor" in
  vim|nvim|both) ;;
  *)
    echo "Invalid editor: $editor" >&2
    usage >&2
    exit 1
    ;;
esac

link_path() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    return
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up $target to $backup"
    mv "$target" "$backup"
  fi

  ln -s "$source" "$target"
}

ensure_bashrc_block() {
  local bashrc="$HOME/.bashrc"
  local marker_start="# bashSettings start"
  local marker_end="# bashSettings end"

  touch "$bashrc"
  if grep -qF "$marker_start" "$bashrc"; then
    return
  fi

  cat >> "$bashrc" <<'EOF'

# bashSettings start
if [ -f ~/.mybashrc ]; then
  . ~/.mybashrc
fi
export PATH="$PATH:$HOME/bin"
# bashSettings end
EOF
}

install_shell() {
  link_path "$repo_dir/.mybashrc" "$HOME/.mybashrc"
  link_path "$repo_dir/bin" "$HOME/bin"
  ensure_bashrc_block
}

install_vim() {
  link_path "$repo_dir/.vimrc" "$HOME/.vimrc"

  if [ ! -d "$HOME/.vim" ]; then
    cp -r "$repo_dir/.vim" "$HOME/.vim"
  fi

  if [ -x "$HOME/.vim/setupVim.sh" ] && [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    (
      cd "$HOME/.vim"
      ./setupVim.sh
    )
  fi
}

install_nvim() {
  if ! command -v nvim >/dev/null 2>&1; then
    cat <<'EOF'
Neovim is not installed or not on PATH.
Install it first, for example on Ubuntu:
  sudo snap install nvim --classic
Then rerun:
  ./setupBashAndVim.sh --editor nvim
EOF
    return 1
  fi

  link_path "$repo_dir/.config/nvim" "$HOME/.config/nvim"
  nvim --headless "+Lazy! sync" +qa
}

install_shell

case "$editor" in
  vim)
    install_vim
    ;;
  nvim)
    install_nvim
    ;;
  both)
    install_vim
    install_nvim
    ;;
esac
