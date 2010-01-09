#!/bin/bash

for orig in *.o.jpg
do
  small=${orig%.o.jpg}.s.jpg
  echo "$orig to $small"
  convert $orig -resize 640x480 $small
done

