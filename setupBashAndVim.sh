#!/bin/bash

ln -s .mybashrc ~/.mybashrc
echo                             >> ~/.bashrc 
echo 'if [ -f .mybashrc ]; then' >> ~/.bashrc 
echo '  . .mybashrc'             >> ~/.bashrc 
echo 'fi'                        >> ~/.bashrc   

ln -s .vimrc ~/.vimrc
cp -r .vim ~/.vim

pushd ~/.vim >> /dev/null
./sutupVim
popd >> /dev/null
