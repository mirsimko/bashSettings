#!/bin/bash

username=$1
server=$2
file=$3

if [ -z $file ]; then
  echo No file to fetch
  exit 1
fi

firstLetter="$(echo $file | head -c 1)" # first letter of the first argument
file="$(echo $file | sed 's|/home/miro|~|g')" # replace /home/miro with ~
if [ "$firstLetter" == "/" ] || [ "$firstLetter" == "~" ]; then
  scp $username@$server:$file .
else
  scp $username@$server:~/$file .
fi

