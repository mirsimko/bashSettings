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
