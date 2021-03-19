#!/bin/bash
maxSize=${1:-2}
echo Max size of the jpeg files is $maxSize MB

# make it in kB
maxSize=$( python -c 'print(round('$maxSize'*1024))' )
echo $maxSize
# target directory
mkdir -p resized

# loop over all .jpg files
for jpegFile in *.jpg *.JPG *.jpeg; do

  # this is to support all JPG, jpg, and jpeg suffixes. If the file does not exist, continue
  if [ ! -f "$jpegFile" ]; then
    continue
  fi

  jpegSize="`du -k "$jpegFile" | awk '{print $1;}'`"

  if [ $jpegSize -gt $maxSize ]; then
    # scale for resizing in %
    scale=$( python -c "print( 100.*($maxSize./$jpegSize.) )" )
    # echo "print 100.*($maxSize./$jpegSize.)"
    echo Resizing "$jpegFile" to $scale % of its size
    convert -resize $scale% "$jpegFile" resized/"$jpegFile"
  else
    # if it is already smaller than the maxSize, just copy
    echo "$jpegFile" already smaller than maximum size
    cp "$jpegFile" resized
  fi

done
# end of loop over all .jpg files
