# bashSettings
Settings of aliases, vim, etc.

## How to install vim plugins

```bash
$ git clone https://github.com/mirsimko/bashSettings.git
```
Copy `.vimrc` and `.vim` to the home directory

in your home run:
```bash
$ cd .vim
$ ./setupVim.sh
```
## To load `.Xresources` (config for xterm)

```bash
$ ./configureXterm.sh
```

## Configuring tmux

Make a link of `.tmux.conf` in your home
in tmux run

```bash
$ tmux source-file ~/.tmux.conf
```
