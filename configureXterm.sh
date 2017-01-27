#!/bin/bash

ln -s .Xresources ~/.Xresources
xrdb -merge ~/.Xresources
