# Call this script with as input file, a file formatted as the callflow.short file.

BEGIN {
  FS = "|"
  CNT = 0
  DEBUG = 0
}
{
  if ($0 !~ "#" ) {

    # IP address only
    ADDRESS[0] = sprintf ("%s", $4)
    ADDRESS[1] = sprintf ("%s", $7)

    # IP address with port
    ADDRPRT[0] = sprintf ("%s:%s", $4, $5)
    ADDRPRT[1] = sprintf ("%s:%s", $7, $8)

    for (i = 0; i <= 1; i++) {
      ADR = ADDRESS[i]
      if (!(ADR in NODES)) {
        # The order in which the nodes appear is important, for this
        # reason 2 arrays are used.  The order is important to keep,
        # as it gives an indication how the SIP messages flow from one
        # system to the other.
        NODES[ADR] = CNT
        POS[CNT] = ADDRESS[i]
        if (DEBUG) printf("Order: %s\nCNT: %s\n", POS[CNT], CNT)
        CNT++
      }

      # Lookup whether the IP address + port have been seen before
      POSITION = NODES[ADR]
      if (DEBUG) printf("pos: %s\n", POSITION)

      L = split(DEVICES[POSITION], DEV, "|")
      Found = 0
      for (j = 0; j <= L; j++) {
        if (DEV[j] == ADDRPRT[i]) {
          Found = 1
          break
        }
      }

      if (Found == 0) {
        L = length(DEVICES[POSITION])
        if (L == 0 ) {
          DEVICES[POSITION] = ADDRPRT[i]
        } else {
          DEVICES[POSITION] = ADDRPRT[i] "|" DEVICES[POSITION]
        }
        if (DEBUG) printf ("Fnd = 0: %s\n", DEVICES[POSITION])
      }
    }
  }

} END {

  # Create an array with node names, the index is the IP address of the node
  if (NODENAMES != "") {
    while ( getline < NODENAMES > 0 ) {
      sub(" ", "|")
      NAMES[$1] = $2
    }
  }

  MAX = length(POS)
  for (i=0; i < MAX; i++) {
    if (POS[i] in NAMES) {
      ID = POS[i]
      ALIAS = NAMES[ID]
    } else {
      ALIAS = POS[i]
    }
    print DEVICES[i], ALIAS
  }
}

