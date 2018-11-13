#!/bin/bash
listid=$(tail -n +2 idmovie.csv)
for i in $listid
do
  nbscript=`jobs | wc -l`
  while [[ $nbscript -gt 20 ]]
  do
    nbscript=`jobs | wc -l`
  done
  ./job.sh $i &
done