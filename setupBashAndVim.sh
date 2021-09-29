#!/bin/bash

ln -s $PWD/.mybashrc ~/.mybashrc
ln -s $PWD/bin ~/bin
echo                             >> ~/.bashrc 
echo 'if [ -f .mybashrc ]; then' >> ~/.bashrc 
echo '  . .mybashrc'             >> ~/.bashrc 
echo 'fi'                        >> ~/.bashrc   
echo                             >> ~/.bashrc
echo 'export PATH=$PATH:~/bin'          >> ~/.bashrc

ln -s $PWD/.vimrc ~/.vimrc
cp -r $PWD/.vim ~/.vim

pushd ~/.vim >> /dev/null
./setupVim.sh
popd >> /dev/null
