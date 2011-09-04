#!/bin/bash
# script to be called with these arguments:
# removedups.sh DESTDIR FRAMEDIR TMPDIR MODE
#   MODE: REMOVE_MIRROR_DUPS_2, REMOVE_MIRROR_DUPS, REMOVE_ALL_DUPS

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
    N=${i##Frame}              # ## is used to remove Frame from FrameXX.html (N is like XX.html)
    #echo $N >&2
    sed "s/ -$//;s/^/${N%%.html} /" <<< $MD5SUM
  done | sort -n > $TMPDIR/md5sums.$$
)

if [[ $MODE = "REMOVE_MIRROR_DUPS" ]]; then
  
  ( echo "$MODE is deprecated, may be removed in the future without notice,"
    echo "  please use \"REMOVE_MIRROR_DUPS_2\" instead."
  ) >&2

  # This mode removes a frame if the prior and the current frame are the same.
  # The frame kept is the first one sent, the current one is removed.
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

elif [[ $MODE = "REMOVE_MIRROR_DUPS_2" ]]; then

  # The md5sum calculation has been performed before already.  Do it
  # here anyway again, as this "remove duplicated frames mode" seems to be
  # the better one.  The others may be removed, including the md5sum
  # processing done above.
  # The code block /^[^#]/ takes care that comments skipped
  awk -F"|" '/^[^#]/ {print $3, $1}' $DESTDIR/callflow.short | while read FRAME TIME; do
    MD5SUM=$(mkmd5sum $DESTDIR/frames/Frame${FRAME}.html | sed 's/ .*//')
    echo "$FRAME|$TIME|$MD5SUM"
  done > $TMPDIR/md5sums.$$

  awk 'BEGIN {
    FS = "|"
    DEBUG = 0

    # In SIP the first retry can be after 0.5 seconds
    MAX_TIME_DELTA = 0.5

    # The number of previous frames to investigate
    MAX_FRAME_DELTA = 5

  } {

    FRAME[NR] = $1
    TIME[NR] = $2
    MD5SUM[NR] = $3

  } END {

    # The first frame can always be printed
    if (DEBUG) print FRAME[1], TIME[1], MD5SUM[1]
    print FRAME[1]

    for (i = 2; i <= NR; i++) {

     if (DEBUG) print "NEW: i =", i

      # p: previous frame
      DELTA = 1
      p = i - DELTA

      SEEN = "no"
      CONT = 1
      while (CONT) {
        
        if (DEBUG) printf "DEBUG 1: i = %d, Frame = %d, Time = %s, MD5SUM = %s\n", i, FRAME[i], TIME[i], MD5SUM[i]
        if (DEBUG) printf "DEBUG 2: p = %d, Frame = %d, Time = %s, MD5SUM = %s\n", p, FRAME[p], TIME[p], MD5SUM[p]

        # Time format is: 11:41:00.134538, use only the seconds (last part)
        # The previous frame may have timestamp 11:40:59.921807
        # The delta in seconds (00.134538 - 59.921807) will be negative for
        # those 2 frames, in this case add 60 seconds to it.
        split(TIME[i], TC, ":")
        split(TIME[p], TP, ":")
        TIME_DELTA = TC[3] - TP[3]
        if ( TIME_DELTA < 0 ) TIME_DELTA += 60
        if ( TIME_DELTA > MAX_TIME_DELTA ) CONT = 0
        if (DEBUG) printf "DEBUG 5: TC = %s, TP = %s, Delta = %s\n", TC[3], TP[3], TIME_DELTA

        if ( TIME_DELTA > MAX_TIME_DELTA ) {
          CONT = 0
          if (DEBUG) printf "DEBUG 9: STOP: passed time delta (%s)\n", MAX_TIME_DELTA
        } else {

          if (MD5SUM[i] == MD5SUM[p]) {
            CONT = 0
            SEEN = "yes"
            if (DEBUG) printf "DEBUG 6: STOP: not unique\n"
          } else {

            DELTA++

            if ( DELTA > MAX_FRAME_DELTA ) {
              CONT = 0
              if (DEBUG) printf "DEBUG 7: STOP: max frame delta (%s) reached\n", MAX_FRAME_DELTA
            } else {

              p = i - DELTA

              if ( p < 1 ) {
                CONT = 0
                if (DEBUG) printf "DEBUG 8: STOP: previous frame array index < 1\n"
              }
            }
          }
        }
      }

      if (SEEN == "no") {
        if (DEBUG) print "UNIQUE:", FRAME[i], TIME[i], MD5SUM[i]
        print FRAME[i]
      }
    }

  }' $TMPDIR/md5sums.$$ > $TMPDIR/pckts.$$

elif [[ $MODE = "REMOVE_ALL_DUPS" ]]; then

  ( echo "$MODE is deprecated, may be removed in the future without notice,"
    echo "  please use \"REMOVE_MIRROR_DUPS_2\" instead."
  ) >&2

  # This mode removes any duplicate package it encounters....
  for M in $(awk '{print $2}' $TMPDIR/md5sums.$$ | sort -u); do
    grep $M $TMPDIR/md5sums.$$ | head -1
  done | awk '{print $1}' | sort -n > $TMPDIR/pckts.$$

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
rm -f $TMPDIR/pckts.$$
rm -f $TMPDIR/md5sums.$$
rm -f $TMPDIR/callflow.short.$$

