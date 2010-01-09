#!/bin/bash

orig=$1
small=${orig%.o.jpg}.s.jpg
echo "$orig to $small"
convert $orig -resize 640x480 $small

