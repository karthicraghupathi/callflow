function make_long_and_short_caches_of_pcap_trace() {

  PCAP_FILE=$1
  unset PREV_CALL_ID
  unset PREV_TIME
  unset PREV_SRC_IP
  unset PREV_DST_IP
  unset PREV_CSEQ

  tshark -r $PCAP_FILE $FARG "$FVAL" -V > $DESTDIR/callflow.long

  # Create a datafile with the data needed to create the callflow.
  # This is done in 2 steps, because of the following reasons:  the tshark command
  # with the '-T fields' argument, provides the IP addresses and SIP CSeq and Call-ID
  # data.  Some additional information about the Call-ID; this field can show up
  # in (at least) 2 ways in SIP messages.  The field can indeed be called "Call-ID",
  # but just "i" in abbreviated SIP messages!  Both formats can be used in 1 call.
  tshark -r $PCAP_FILE $FARG "$FVAL" -t a -T fields -E separator='|' \
    -e frame.number -e ip.src -e ip.dst -e sip.CSeq -e sip.Call-ID \
    -e sdp.connection_info -e sdp.media -e sdp.media_attr -e ipv6.src -e ipv6.dst | awk '
  BEGIN {
    FS = "|"
    OFS = "|"
    NOC = 1 # Number Of Call-IDs
  }
  {
    # Map the often very long Call-IDs to a short index, with only 1 or 2 digits
    if (( $5 != "" ) && ( CALLID[$5] == "" )) {
      CALLID[$5] = NOC
      NOC++
    }

    # Process connection info and obtain the ip addr
    sub("IN IP4 ", "", $6)

    # Process SDP media info and obtain the port and RTP format
    split($7, S, " ")
    PORT = S[2]
    FORMAT = S[4]

    # Process SDP media attributes and get the direction information
    if ($8 ~ "sendrecv") {
      DIRECTION = "sendrecv"
    } else if ($8 ~ "recvonly") {
      DIRECTION = "recvonly"
    } else if ($8 ~ "sendonly") {
      DIRECTION = "sendonly"
    } else if ($8 ~ "inactive") {
      DIRECTION = "inactive"
    } else {
      DIRECTION = ""
    }

    # The printf line below results in the following fields and order.  For now we assume
    # that the delivered media contains audio, but that may change one day when
    # for example audio and video are involved.
    #
    # No Description
    #  1 frame.number
    #  2 ip.src
    #  3 ip.dst
    #  4 sip.CSeq
    #  5 sip.Call-ID
    #  6 sdp.connection_info (ip addr)
    #  7 sdp.media (audio port audio format)
    #  8 sdp.media_attr (audio direction (sendrecv, sendonly, recvonly))
    #  9 ipv6.src
    # 10 ipv6.dst
    # Its an IPv6 address we have to fill source and destination address with the correct IP version
    if (length($10) > 1) {
      CURR_SRC_IP=$9
      CURR_DST_IP=$10
    } else {
      CURR_SRC_IP=$2
      CURR_DST_IP=$3
    }

    printf "%s||%s|%s|%s|{%s}|%s|%s|%s|%s\n", $1, CURR_SRC_IP, CURR_DST_IP, $4, CALLID[$5], $6, PORT, FORMAT, DIRECTION

  }' > $TMPDIR/${PRGNAME}-tshark-1.$$

  # The second step in getting SIP data required by callflow.  This step delivers
  # the source and destination ports independent whether the datagram is UDP or
  # TCP based.  As SIP can be delivered over UDP or TCP using this tshark command
  # seems to be good choice.  Further more this command delivers the frame information
  # (summary), that can not be obtained with tshart '-T fields' command above.
  #
  # For messages containing ISUP payload this step could deliver the IP addresses
  # when using % variables %ns and %nd (network source and destination).  If the
  # % variables %s and %d are used the highest source and destination addresses are
  # used, in case of ISUP message that are the OPC and DPC data, for details see
  # wireshark bug 5969.
  #
  # The available % variables can be found at:
  #   http://anonsvn.wireshark.org/viewvc/trunk/epan/column.c?view=markup
  #
  # Information about the stream editor (sed) manipulations:
  # - The string (ITU) shows up in the protocol description "ISUP(ITU)".
  #   awk doesn't like the "(" and ")", hence remove them.
  # - Short the string "with session description" to just SDP.
  # - Megaco has a "|" in its info string, this character is however the
  #   field separator in the output file, remove it.  The actual string
  #   being removed is " |=".
  tshark -r $PCAP_FILE $FARG "$FVAL" -t a \
    -o 'gui.column.format: "No.", "%m", "Time", %t, "Protocol", "%p", "srcport", %S, "dstport", %D, "Info", "%i"' |
      sed -e 's/^[[:blank:]]*//' \
        -e 's/[[:blank:]]*|=/=/' \
        -e 's/ Status: / /' \
        -e 's/ Request: / /' \
        -e 's/(ITU)//' \
        -e 's/SCCP (Int. ITU)/SCCP/' \
        -e 's/with session description/SDP/g' | awk '{

    # Time value ($2) looks like: 13:35:43.868013000
    # The last zeros are unwanted.  Desired time string: 13:35:43.868013
    # This string has a length of 16.
    if (length($2) > 16 ) sub ("000$", "", $2)

    split($0, A, " ")

    # The line below results in the following fields and order.
    #
    # No Description
    #  1 frame number
    #  2 time
    #  3 protocol
    #  4 srcport
    #  5 dstport
    #  6 info

    for (i = 1; i <= 5; i++) {
      printf "%s|", $i
    }

    L = length(A)
    for (i = 6; i < L; i++) {
      printf "%s ", $i
    }

    printf "%s\n", $L

  }' > $TMPDIR/${PRGNAME}-tshark-2.$$

  # Join the 2 datafiles that have been obtained above together
  # When merged the first field (frame number) in the file ${PRGNAME}-tshark-2.$$
  # is combined with the first field (frame.number) in the file ${PRGNAME}-tshark-1.$$
  # So after the merge the total number of fields is 1 less, than the total number
  # of fields.
  join -t "|" --nocheck-order $TMPDIR/${PRGNAME}-tshark-1.$$ $TMPDIR/${PRGNAME}-tshark-2.$$ > $TMPDIR/${PRGNAME}-tshark-3.$$

  # Order the fields
  awk 'BEGIN {
    FS = "|"

    # The order in which the fields will be arranged in the output file
    #
    # No Description
    #  1 time
    #  2 tracefile
    #  3 frame.number
    #  4 ip.src
    #  5 ip.srcport 
    #  6 session information
    #  7 ip.dst
    #  8 ip.dstport
    #  9 protocol
    # 10 info field
    # 11 SIP CSeq
    # 12 Connection info (IP addr)
    # 13 Media info (Port)
    # 14 Media info (Protocol)
    # 15 Media attribute direction

    # The array (A) that the 'split' command creates, maps the input fields
    # to the output file order.  As example: input field 11 is mapped to
    # output field 1 and input field 5 is mapped to output field 11.
    split("11 2 1 3 13 6 4 14 12 15 5 7 8 9 10", A, " ")
  }
  {
    # Look for "200 OK" or "200 Ok" and add the SIP method, from the
    # call sequence field to the 200 OK message.
    #
    # Attention: use the input fields values and not the ones mentioned in
    # the BEGIN part.
    # - $5 contains the sip.CSeq data.
    # - $8 contains the protocol
    # - $11 contains the info field data.
    if (($8 ~ "SIP") && ($11 ~ "200 O")) {
      # split the call sequence message (#ID SIP_method)
      split($5, S, " ")
      $11 = sprintf("%s (%s)", $11, S[2])
    }

    # Perform the actual mapping of the input to the output fields
      L = length(A)
      for (i = 1; i < L; i++) {
        printf "%s|", $A[i]
      }

      printf "%s\n", $A[L]


  }' $TMPDIR/${PRGNAME}-tshark-3.$$ > $TMPDIR/${PRGNAME}-tshark-4.$$

  # It sometimes happens that the frames in the trace are not time
  # ordered (they are ordered at frame number), for this reason
  # re-order the callflow.short cache on time.
  # Example of a wrong order:
  # 13.14.15.625340|1|.....
  # 13.14.15.625360|2|.....
  # 13.14.15.625350|3|..... <<< this one is at the wrong spot
  # The timestamp is the first field in the callflow.short cache, hence
  # re-ordering on time is rather easy using just sort.
 sort -o $TMPDIR/${PRGNAME}-tshark-4.$$ $TMPDIR/${PRGNAME}-tshark-4.$$

 awk 'BEGIN {
    FS = "|"
    OFS = "|"
  }
  {
    # The order in which the fields will be arranged in the output file
    #
    # No Description
    #  1 time
    #  2 tracefile
    #  3 frame.number
    #  4 ip.src
    #  5 ip.srcport
    #  6 session information
    #  7 ip.dst
    #  8 ip.dstport
    #  9 protocol
    # 10 info field
    # 11 SIP CSeq
    # 12 Connection info (IP addr)
    # 13 Media info (Port)
    # 14 Media info (Protocol)
    # 15 Media attribute direction

    # Convert timestamp onto seconds to calculate time difference between packets
    TIME=$1
    m=split(TIME,t,":")
    n=split(PREV_TIME,w,":")
    FIRSTTIME= (t[1]*3600) + (t[2]*60) + t[3]
    SECONDTIME= (w[1]*3600) + (w[2]*60) + w[3]
    TIME_DIFF=(FIRSTTIME - SECONDTIME)

    # Store current IPs
    CURR_SRC_IP=$4
    CURR_DST_IP=$7

    # 1) if protocol is SIP lets start the duplication removal
    # 2) if previous src&dst IPs are different > OK
    # 3) if IPs are the same and Call-Id, CSEQ is same, but time diff is bigger than 0.5sec > OK (retransmission)
    # 4) if diff is less than 2 sec > drop the packet
    # 5) keep everything else
    if ($9 ~ "SIP") {
        if ((PREV_SRC_IP != CURR_SRC_IP) &&
            (PREV_DST_IP != CURR_DST_IP)) {
              print $0
      } else if ((PREV_CALL_ID == $10) &&
                 (PREV_CSEQ == $11)   &&
                 (TIME_DIFF >= 0.5)) {
              print $0
      } else if ((PREV_CALL_ID == $10) &&
                 (PREV_CSEQ == $11)   &&
                 (TIME_DIFF < 0.5)) {
              # Do Nothing just drop the packet (silently)
      } else {
              print $0
      }
    } else {
        # Not an SIP Packet -> do not remove duplicates
        print $0
    }

    # Store necessary information to eliminate duplicated packets in the next round.
    PREV_TIME    = TIME
    PREV_CALL_ID = $10
    PREV_CSEQ    = $11
    PREV_SRC_IP  = CURR_SRC_IP
    PREV_DST_IP  = CURR_DST_IP

  }' $TMPDIR/${PRGNAME}-tshark-4.$$ > $DESTDIR/callflow.short

  rm $TMPDIR/${PRGNAME}-tshark-[1234].$$
}

