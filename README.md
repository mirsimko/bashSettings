# bashSettings
Settings of aliases, vim, etc.

## How to install vim plugins

```bash
$ git clone https://github.com/mirsimko/bashSettings.git
```
Copy .vimrc and .vim to the home directory

in your home run:
```bash
$ cd .vim
$ ./setupVim.sh
```
## To load .Xresources (config for xterm)

In your home run:
```bash
$ ln -s bashSettings/.Xresources
$ xrdb -merge ~/.Xresources
```
