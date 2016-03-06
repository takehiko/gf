#!/bin/bash

# . excel/generator.sh

for n in 2 3 4 5 6 7 8
do
    ruby lib/gf.rb -t $n -m 0 -x excel/triangle${n}.xlsx
done

for n in 4 5 6 7 8 9 10 11
do
    ruby lib/gf.rb -p $n -m 0 -x excel/trigonal${n}.xlsx
    ruby lib/gf.rb -p $n -m 4 -x excel/trigonal${n}_m4.xlsx
done

for n in 5 7 9 21
do
    ruby lib/gf.rb -y $n -m 0 -x excel/yagura${n}.xlsx
    ruby lib/gf.rb -y $n -m 4 -x excel/yagura${n}_m4.xlsx
done
