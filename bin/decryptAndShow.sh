#!/bin/bash

gpgdir="$1"

if echo "$gpgdir" | grep -q '.gpg'; then
  echo decrypting file "$gpgdir"
else
  echo The argument has to be a .gpg file  ... exiting >&2
  exit 1
fi

gpg "$gpgdir"

tarfile=$( echo "$gpgdir" | sed 's/.gpg//g' )
if [ ! -f "$tarfile" ]; then
  echo Wrong passphrase or the gpg file did not contain a tar file ... exiting >&2
  exit 1
fi
tar -xzf "$tarfile"
# echo "$tarfile"

dir=$( echo "$tarfile" | sed 's/.tar//g' )
# echo $dir
if [ -d "$dir" ]; then  
  # if the encrypted file contains a dirrectory, go there
  # if not, the jpegs will be decrypted directly
  pushd "$dir" >> /dev/null
fi
eog *.JPG *.jpg

read -n 1 -s -r -p "Press any key to continue"

if [ -d "../$dir" ]; then
  popd >> /dev/null
fi
echo
echo Deleting decrypted content ...

if [ -d "$dir" ]; then
  srm -rflv "$dir"
else
  srm -flv IMG_183[6-9].JPG
fi
srm -flv "$tarfile"

