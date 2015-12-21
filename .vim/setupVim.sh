#!/bin/bash

echo '_________________________________________________________'
echo '_________                                     ___________'
echo '_________         Vim setup by Miro           ___________'
echo '_________________________________________________________'
echo Creating new directories .vim/bundle and .vim/autoload ...
mkdir bundle autoload
echo Installing Pathogen ...
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
echo '_________________________________________________________'
echo Installing Vundle  ...
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo '_________________________________________________________'

echo opening vim to install plugins ...
vim -c "PluginInstall"
echo '_________________________________________________________'
echo done
