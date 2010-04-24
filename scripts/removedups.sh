#!/bin/bash
# script to be called with these parameters:
# mkmdsum DESTDIR FRAMEDIR TMPDIR

function mkmd5sum {
  grep -v "Arrival Time" $1 |
    grep -v "Frame [:digit:]*" |
    grep -v "Resent Packet" |
    grep -v "Suspected resend of frame" |
    grep -v "Request Frame: [:digit:]*" |
    grep -v "Response Time (ms): [:digit:]*" |
    grep -v "Release Time (ms): [:digit:]*"  | md5sum
}


if [ $# -ne 3 ]
then
  echo Bad arguments $#
  exit 1
fi

DESTDIR=$1
FRAMEDIR=$2
TMPDIR=$3

#echo Making md5sums >&2
( cd $FRAMEDIR
  for i in Frame*html; do
    #echo $i >&2
    MD5SUM=$(mkmd5sum $i)
    N=${i##Frame}		# ## is used to remove Frame from FrameXX.html (N is like XX.html)
    #echo $N >&2
    sed "s/-$//;s/^/${N%%.html} /" <<< $MD5SUM
  done > $TMPDIR/md5sums.$$
)

#echo Looking for unique frames >&2
for M in $(awk '{print $2}' $TMPDIR/md5sums.$$ | sort -u); do
  grep $M $TMPDIR/md5sums.$$ | head -1
done | awk '{print $1}' | sort -n  > $TMPDIR/pckts.$$

#echo "Trick on callflow.short (remove left spaces (left trim))"
sed 's/^ *//' $DESTDIR/callflow.short > $TMPDIR/callflow.short.$$

# Join the files
for i in $(cat $TMPDIR/pckts.$$); do
  grep "^$i " $TMPDIR/callflow.short.$$
done > $DESTDIR/callflow.short.new

#Remove temp files
rm -f $TMPDIR/md5sums.$$
rm -f $TMPDIR/pckts.$$
rm -f $TMPDIR/callflow.short.$$

