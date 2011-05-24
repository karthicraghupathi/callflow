#!/bin/bash
# script to be called with these arguments:
# removedups.sh DESTDIR FRAMEDIR TMPDIR MODE
#   MODE: REMOVE_MIRROR_DUPS, REMOVE_ALL_DUPS

function mkmd5sum {
  grep -v "title" $1 |
    grep -v "Arrival Time" |
    grep -v "Frame [[:digit:]]*" |
    grep -v "Resent Packet" |
    grep -v "Suspected resend of frame" |
    grep -v "Request Frame: [[:digit:]]*" |
    grep -v "Response Time (ms): [[:digit:]]*" |
    grep -v "Release Time (ms): [[:digit:]]*"  | md5sum
}

if [ $# -ne 4 ]; then
  echo "Bad arguments: $#"
  exit 1
fi

DESTDIR=$1
FRAMEDIR=$2
TMPDIR=$3
MODE=$4

#echo Making md5sums >&2
( cd $FRAMEDIR
  for i in Frame*html; do
    #echo $i >&2
    MD5SUM=$(mkmd5sum $i)
    N=${i##Frame}		# ## is used to remove Frame from FrameXX.html (N is like XX.html)
    #echo $N >&2
    sed "s/-$//;s/^/${N%%.html} /" <<< $MD5SUM
  done | sort -n > $TMPDIR/md5sums.$$
)

if [[ $MODE = "REMOVE_MIRROR_DUPS" ]]; then
  
  # This mode removes a package if the subsequent frames are the same.
  # The package that is kept is the first one sent, the subsequent one is skipped
  # This is often encountered on traces that are obtained via port mirroring
  # on a router.

  awk '{
    FRAMES[NR] = $0

  } END {
     
    # Print first frame number
    split(FRAMES[1], F, " ")
    print F[1]
    PREV_MD5 = F[2]

    MAX = length(FRAMES)
    for (i=2; i<=MAX; i++) {

      split(FRAMES[i], F, " ")
      CUR_MD5 = F[2] 

      if (CUR_MD5 != PREV_MD5) {
        # Print the current frame number
        printf "%s\n", F[1]
      }

      PREV_MD5 = CUR_MD5
    }

  }' $TMPDIR/md5sums.$$ > $TMPDIR/pckts.$$

elif [[ $MODE = "REMOVE_ALL_DUPS" ]]; then

  # This mode removes any duplicate package it encounters....
  for M in $(awk '{print $2}' $TMPDIR/md5sums.$$ | sort -u); do
    grep $M $TMPDIR/md5sums.$$ | head -1
  done | awk '{print $1}' | sort -n  > $TMPDIR/pckts.$$

else
  echo "error: unknow mode: \"$MODE\"" >&2
  exit 1
fi

# Output the frame (number) that are not duplicated
awk -F"|" -v PKGS="$TMPDIR/pckts.$$" 'BEGIN {
  while ( getline < PKGS > 0 ) {
    # $1 contains the frame number to be included
    cmd[$1] = "INCLUDE"
  }
}
{
  # The user may have added comments to the cache (callflow.short), these
  # comments must be kept!
  if ($1 ~ "#" ) {
    print $0

    # $3 from callflow.short contains the frame number
  } else if (cmd[$3] == "INCLUDE") print $0

}' $DESTDIR/callflow.short > $DESTDIR/callflow.short.new

# Provide statistics
wc -l $TMPDIR/md5sums.$$ $TMPDIR/pckts.$$ | awk '
  NR == 1 { FRAMES = $1 }
  NR == 2 { LEFT = $1 }
END {
  REMOVED = FRAMES - LEFT
  if ( REMOVED > 0 ) {
    if ( REMOVED == 1 ) {
      print "Removed 1 duplicate frame"
    } else {
      PERC = ( REMOVED / FRAMES) * 100
      printf("Removed %d (~%d%%) duplicate frames\n", REMOVED, PERC )
    }
  } else {
    print "No duplicate frames found"
  }
}' >&2

#Remove temp files
rm -f $TMPDIR/md5sums.$$
rm -f $TMPDIR/pckts.$$
rm -f $TMPDIR/callflow.short.$$

