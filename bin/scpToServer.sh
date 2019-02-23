#!/bin/bash

file="$1"
user="$2"
server="$3"

scp $file $user@$server:~
