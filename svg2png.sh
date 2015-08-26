qlmanage -t -s $2 -o . $1
file=$1.png
mv $file "${file%.svg.png}_$2.png"