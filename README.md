# bashSettings

Personal shell, terminal, Vim, and Neovim configuration.

## Installation

```bash
$ git clone https://github.com/mirsimko/bashSettings.git
$ cd bashSettings
```

The setup script always links the shell config (`~/.mybashrc`) and `~/bin`.
Choose which editor config to install with `--editor`.

### Classic Vim

```bash
$ ./setupBashAndVim.sh --editor vim
```

This links `~/.vimrc`, copies `.vim`, and runs the Vundle-based Vim plugin
installer when Vundle is not already present.

### Neovim

```bash
$ ./setupBashAndVim.sh --editor nvim
```

This links:

```text
~/.config/nvim -> ~/bashSettings/.config/nvim
```

The Neovim setup bootstraps `lazy.nvim` automatically and installs the migrated
Vim plugins plus `codex.nvim`.

If `nvim` is missing on Ubuntu, install it first:

```bash
$ sudo snap install nvim --classic
```

### Vim and Neovim

```bash
$ ./setupBashAndVim.sh --both
```

### Codex in Neovim

The Neovim setup includes `rhart92/codex.nvim`. Default mappings:

```text
,cc  Toggle Codex
,cs  Send visual selection to Codex
```

The plugin runs the existing `codex` CLI from inside Neovim. It does not add Vim
mode to the Codex CLI prompt itself.

The Codex window is a Neovim terminal buffer. To leave terminal input mode:

```text
Esc Esc
```

When the terminal is in normal mode, the buffer is intentionally not editable.
If you see `E21: Cannot make changes, 'modifiable' is off`, go back to terminal
input mode:

```text
i
Enter
,ti
```

Window navigation works from normal buffers and from the Codex terminal:

```text
Alt-h  Move to the left window
Alt-j  Move to the lower window
Alt-k  Move to the upper window
Alt-l  Move to the right window
```

From inside the Codex terminal, these also work:

```text
Ctrl-w h  Move to the left window
Ctrl-w j  Move to the lower window
Ctrl-w k  Move to the upper window
Ctrl-w l  Move to the right window
Ctrl-w Ctrl-w  Cycle windows
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

## Swapping CapsLock and Escape in the 'US' keyboard layout with Gnome-Shell

This is useful when using vim. Other keyboard layouts other than US stay unaffected. Most Linux distros use xkb, in which it is very easy to make keyboard swaps. A comprehensive guide on how to do that can be found [here][1]

First, in the file `/usr/share/X11/xkb/symbols/us` add this line in the section `"basic"`
```
key <CAPS> { [ Escape ] };
```
Now, you want to put the settings in effect. Gnome uses its own settings layer on top of XKB (see [e.g. this page][1]) so you must specify that you want to use xkb for your chosen layout. In the command line, write
```bash
$ gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'cz')]"
$ gsettings set org.gnome.desktop.input-sources xkb-options "['caps:swapescape','grp:alt_shift_toggle']"
```
Now, ESC and CapsLock should be swapped in the US layout. You can add other keyboard layouts (e.g. Japanese Mozc) now.

[1]: https://medium.com/@damko/a-simple-humble-but-comprehensive-guide-to-xkb-for-linux-6f1ad5e13450

## For colors in less:

In your home, make a link to .lessfilter. Install pygments or python-pygments.
