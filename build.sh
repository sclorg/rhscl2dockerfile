#!/usr/bin/bash

for dir in $(find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n')
do
 cd $dir
 docker build -t $dir .
 cd .. 
done

