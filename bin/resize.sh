#!/bin/bash
maxSize=${1:-2}
echo Max size of the jpeg files is $maxSize MB

for jpegFile in *.jpg; do
  jpegSize="`du -m "$jpegFile" | awk '{print $1;}'`"
  if [ $jpegSize -gt $maxSize ]; then
    # scale=$(printf %.3f $(( $jpegSize / $maxSize )) )
    scale=$( python -c "print 100.*($maxSize./$jpegSize.)" )
    # echo "print 100.*($maxSize./$jpegSize.)"
    echo Resizing "$jpegFile" to $scale % of its size
    convert -resize $scale% "$jpegFile" resized/"$jpegFile"
  fi

  # convert -resize "$jpegFile"
done
