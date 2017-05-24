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
pushd "$dir" >> /dev/null
eog *

popd >> /dev/null
srm -rfl "$dir"
srm -l "$tarfile"

