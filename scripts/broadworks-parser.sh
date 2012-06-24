function make_long_and_short_caches_of_broadworks_log() {

  # TODO: make BW_IP_ADDR configurable from the command line
  [[ -z $BW_IP_ADDR ]] && BW_IP_ADDR=127.0.0.1

  awk -v destDir=$DESTDIR -v bwIpAddr=$BW_IP_ADDR 'BEGIN {
    FRAME_NR = 1
    LOG_MSG_LINE_NR = 0
    NOC = 1  # Number Of Call-IDs
  }
  {
    if ($1 ~ "^20[0-9][0-9].[0-1][0-9].[0-3][0-9]$") {

      if (LOG_MSG_TYPE == "sip") {

        FILENAME = destDir "/callflow.long"

        printf "Frame %d: \n", FRAME_NR > FILENAME
        printf "%s\n", LOG_MSG[0] > FILENAME
        printf "User Datagram Protocol\n" > FILENAME

        for (i = 1; i <= LOG_MSG_LINE_NR; i++) {

          printf "    %s\n", LOG_MSG[i] > FILENAME

          if (LOG_MSG[i] ~ "udp" && LOG_MSG[i] ~ "Bytes") {
            printf "Session Initiation Protocol\n" > FILENAME
            printf "    Request-Line: %s\n", LOG_MSG[++i] > FILENAME

          } else if ( LOG_MSG[i] ~ "m=audio" ) {
            PROT = "SIP/SDP"
            split(LOG_MSG[i], S, " ")
            PORT = S[2]
            FORMAT = S[4]
            delete S  # remove the array, so it can be safely re-used
          } else if ( LOG_MSG[i] ~ "c=IN IP4" ) {
            SDP_IP_ADDR = LOG_MSG[i]
            sub("c=IN IP4 ", "", SDP_IP_ADDR)
          }
        }

        if (REQ_URI == "200 OK") {
          split(CSEQ, S, " ")
          REQ_URI = sprintf("200 OK (%s)", S[2])
            delete S  # remove the array, so it can be safely re-used
        }

        if (PROT == "SIP/SDP") {
          # Remove trailing spaces
          sub(" *$", "", REQ_URI)
          REQ_URI = sprintf("%s, SDP", REQ_URI)
        }

        FILENAME = destDir "/callflow.short"
        printf "%s||%s|%s|%s|{%s}|%s|%s|%s|%s|%s|%s|%s|%s|\n", TIME, FRAME_NR, IP_SRC_ADDR,
          IP_SRC_PRT, SESSIONID, IP_DEST_ADDR, IP_DEST_PRT, PROT, REQ_URI, CSEQ,
          SDP_IP_ADDR, PORT, FORMAT > FILENAME

        FRAME_NR++

        # Reset SIP message variables
        CSEQ = ""
        FORMAT = ""
        IP_DEST_ADDR = ""
        IP_DEST_SRC = ""
        IP_SRC_ADDR = ""
        IP_SRC_SRC = ""
        LOG_MSG_TYPE = ""
        PORT = ""
        PROT = "SIP"
        REQ_URI = ""
        SDP_IP_ADDR = ""
        SESSIONID = ""
      }

      TIME = $2

      # Reset log variables
      delete LOG_MSG
      LOG_MSG_LINE_NR = 0
    }

    LOG_MSG[LOG_MSG_LINE_NR] = $0

    # A[1] contains the SIP method.  This step is needed as lines
    # may sometimes look like:
    #    Allow:ACK,BYE,CANCEL,INFO,INVITE
    split($1, A, ":")
    if (A[1] == "ACK" ||
        A[1] == "BYE" ||
        A[1] == "INFO" ||
        A[1] == "INVITE" ||
        A[1] == "PRACK" ||
        A[1] == "SIP/2.0") {

      LOG_MSG_TYPE = "sip"

      REQ_URI = $0
      sub ("SIP/2.0", "", REQ_URI)

      # Remove unwanted white space at the beginning of the string
      sub ("^ ", "", REQ_URI)
    }

    if (LOG_MSG_TYPE == "sip") {

      if (A[1] == "Call-ID") { 
        if (A[2] == "") {
          CALLID = $2
        } else {
          CALLID = A[2]
          sub("^ ", "", CALLID)
        }

        # Map the often very long Call-IDs to a short index,
        # with only 1 or 2 digits
        if (CALLIDS[CALLID] == "") {
          CALLIDS[CALLID] = NOC
          NOC++
        }

        # Use the shortened callid
        SESSIONID = CALLIDS[CALLID]

      } else if (A[1] == "CSeq") {
        CSEQ = $0
        sub ("CSeq:", "", CSEQ)

        # Remove unwanted white space at the beginning of the string
        sub ("^ ", "", CSEQ)
      } 

    } else if ($1 == "udp" && $3 == "Bytes") {

        # Process the line:
        #    udp 1339 Bytes OUT to 10.48.43.13:5060

        if ($4 == "OUT") {
          IP_SRC_ADDR = bwIpAddr
          IP_SRC_PRT = "5060"
          split($6, I, ":") 
          IP_DEST_ADDR = I[1]
          IP_DEST_SRC = I[2]
        } else if ($4 == "IN") {
          split($6, I, ":") 
          IP_SRC_ADDR = I[1]
          IP_SRC_SRC = I[2]
          IP_DEST_ADDR = bwIpAddr
          IP_DEST_PRT = "5060"
        }
      }

    LOG_MSG_LINE_NR++

  }' $1
}

