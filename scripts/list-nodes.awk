# Call this script with as input file, a file formatted as the callflow.short file.

BEGIN {
  FS = "|"
  CNT = 0
}
{
  if ($0 !~ "#" ) {

    ADDRESS[0] = sprintf ("%s:%s", $4, $5)
    ADDRESS[1] = sprintf ("%s:%s", $7, $8)

    for (i=0; i <= 1; i++) {
      ADR = ADDRESS[i]
      if (NODES[ADR] != 1) {
        # The order in which the nodes appear is important, for this
        # reason 2 arrays are used.  The order is important to keep as
        # it gives an indication how the SIP messages flow from one
        # system to the other.
        NODES[ADR] = 1
        ORDER[CNT] = ADDRESS[i]
        # printf("Order: %s\nCNT: %s\n", ORDER[CNT], CNT)
        CNT++
      }
    }
  }

} END {
  MAX = length(ORDER)
  for (i=0; i < MAX; i++) {
    print ORDER[i]
  }

}

