#!/bin/bash

ln -s ~/bashSettings/.Xresources ~/.Xresources
xrdb -merge ~/.Xresources
