# Hexadecimal to decimal convertor
function hex2dec(str) {
  hstr = "0123456789abcdef"
  res = 0
  n = split(tolower(str), digit, "")

  for(j = 1; j <= n; j++) {
    num = index(hstr, digit[j]) - 1
    res = res + (num*16^(n-j))
  }

  return res
}

BEGIN {
  first = 1
}

/^Frame [0-9]+: (.*)/ {
  # New frame, closing <pre> and html> from previous frame before compute new filename
  if (first == 0) {

    if (protocol == "DATA") {
      printf "\n" > filename
      printf "<div class=\"sip\">Raw data</div>\n" > filename
      printf "<hr/>\n" > filename
      L = length(PL)
      for (i = 0; i <= L; i++) {
        print PL[i] > filename
      }
    }

    printf "  </pre>\n" >filename
    printf " </body>\n" >filename
    printf "</html>\n" >filename
    printf "\n" >filename
  } else {
    first = 0
  }

  nbr = $2
  sub (":", "", nbr)
  filename = destDir "/frames/Frame" nbr ".html"
  printf "<html>\n" >filename
  printf " <head>\n" >filename
  printf "  <link rel=\"stylesheet\" type=\"text/css\" href=\"callflow.css\" />\n" >filename
  # The style tag is actually not desired, but it is needed as otherwise the 
  # SIP messages are displayed incorrectly in dynamic presentation mode.
  # The java script used in the dynamic presentation mode does not read the stylesheet.
  printf "  <style>\n" >filename
  printf "   div.sip {display: inline}\n" >filename
  printf "   div.media {display: inline}\n" >filename
  printf "  </style>\n" >filename
  printf "  <title>callflow - frame %s</title>\n", nbr >filename
  printf " </head>\n" >filename
  printf " <body>\n" >filename
  printf "  <pre class=\"msg\">\n" >filename
  print $0 >filename

  # Print Arrival Time
  getline
  gsub("^ *", "")
  print $0 >filename

  discard = 1
  protocol = ""
}

/^Internet Protocol,/ {
  print $0 > filename
  discard = 1
}
/^Internet Protocol$/ {
  discard = 0
}
/^User Datagram Protocol,/ {
  print $0 >filename
  discard = 1
}
/^User Datagram Protocol$/ {
  discard = 0
}
/^Transmission Control Protocol,/ {
  print $0 >filename
  discard = 1
}
/^Transmission Control Protocol$/ {
  discard = 0
}
/^Internet Control Message Protocol/ {
  discard = 0
}
/^Session Initiation Protocol/ {
  discard = 0
  protocol = "SIP"
  printf "\n" > filename
}

/^Diameter Protocol/ {
  discard = 0
}

/^WebSocket Protocol/ {
  discard = 0
}

/^Hypertext Transfer Protocol/ {
  discard = 0
}

/^Call Specification Language/ {
  discard = 0
}

/^Stream Control Transmission Protocol/ {
  discard = 0
  protocol = "SCTP"
  printf "\n" > filename
}

/^Data/ {
  discard = 0
  protocol = "DATA"
  delete PL
  id = 0
  printf "\n" > filename
  printf "<div class=\"sip\">Fragmented data</div>\n" > filename
}

/^MEGACO/ {
  discard = 0
  protocol = "MEGACO"
  printf "\n" > filename
}

{
  if (discard == 0) {

    gsub("&","\\&amp;")
    gsub(">","\\&gt;")
    gsub("<","\\&lt;")

    if ((protocol == "SIP") || (protocol == "MEGACO"))  {

      MARK = "no"
      # Abbreviated SIP messages
      if ($1 == "c:" ) MARK = "sip"
      if ($1 == "f:" ) MARK = "sip"
      if ($1 == "i:" ) MARK = "sip"
      if ($1 == "k:" ) MARK = "sip"
      if ($1 == "l:" ) MARK = "sip"
      if ($1 == "m:" ) MARK = "sip"
      if ($1 == "t:" ) MARK = "sip"
      if ($1 == "v:" ) MARK = "sip"

      # SIP messages
      if ($0 ~ "MEGACO" ) MARK = "sip"
      if ($0 ~ "Session Initiation Protocol" ) MARK = "sip"
      if ($1 ~ "Accept:" ) MARK = "sip"
      if ($1 ~ "Alert-Info:" ) MARK = "sip"
      if ($1 ~ "Allow:" ) MARK = "sip"
      if ($1 ~ "Allow-Events:" ) MARK = "sip"
      if ($0 ~ "Call-ID:" ) MARK = "sip"
      if ($1 ~ "Charge:" ) MARK = "sip"
      if ($1 ~ "Contact:" ) MARK = "sip"
      if ($1 ~ "Content-Disposition:" ) MARK = "sip"
      if ($1 ~ "Content-Length:" ) MARK = "sip"
      if ($1 ~ "Content-Type:" ) MARK = "sip"
      if ($1 ~ "CSeq:" ) MARK = "sip"
      if ($1 ~ "Date:" ) MARK = "sip"
      if ($1 ~ "Expires:" ) MARK = "sip"
      if ($1 ~ "From:" ) MARK = "sip"
      if ($1 ~ "Min-SE:" ) MARK = "sip"
      if ($1 ~ "P-[A-Z][a-z].*:" ) MARK = "sip"
      if ($1 ~ "Privacy:" ) MARK = "sip"
      if ($1 ~ "Proxy-Authenticate:" ) MARK = "sip"
      if ($1 ~ "RAck:" ) MARK = "sip"
      if ($1 ~ "Remote-Party-ID:" ) MARK = "sip"
      if ($1 ~ "Require:" ) MARK = "sip"
      if ($1 ~ "Request-Line:" ) MARK = "sip"
      if ($1 ~ "Request-Disposition:" ) MARK = "sip"
      if ($1 ~ "Route:" ) MARK = "sip"
      if ($1 ~ "RSeq:" ) MARK = "sip"
      if ($1 ~ "Server:" ) MARK = "sip"
      if ($1 ~ "Supported:" ) MARK = "sip"
      if ($1 ~ "Timestamp:" ) MARK = "sip"
      if ($1 ~ "To:" ) MARK = "sip"
      if ($1 ~ "User-Agent:" ) MARK = "sip"
      if ($1 ~ "Via:" ) MARK = "sip"

      # SDP part
      if ($0 ~ "Session Description Protocol") MARK = "media"
      if ($0 ~ "Connection Information") MARK = "media"
      # Use ... here.  Actually "(a)" should be used, but awk does not like the
      # parenthesis (), workaround it with the dots.
      if ($0 ~ "Media Attribute .a.:") MARK = "media"
      if ($0 ~ "Media Description, name and address") MARK = "media"
      if ($0 ~ "Owner/Creator, Session Id") MARK = "media"
      if ($0 ~ "Session Attribute .a.:") MARK = "media"
      if ($0 ~ "Session Description Protocol Version") MARK = "media"
      if ($0 ~ "Session Name") MARK = "media"
      if ($0 ~ "Time Description, active time") MARK = "media"

      if (MARK == "sip") {
        printf "<div class=\"sip\">%s</div>\n", $0 > filename

      } else if (MARK == "media") {
        printf "<div class=\"media\">%s</div>\n", $0 > filename

      } else {
        print $0 > filename
      }

    } else if (protocol == "DATA") {

      # Memorize the current PayLoad (PL) line, so it can be dumped
      # in a raw data block later
      PL[id] = $0
      id++

      # The payload has the following format:
      # 0000  74 2d 4c 65 6e 67 74 68 3a 20 32 31 33 0d 0a 50   t-Length: 213..P
      # 0010  2d 41 73 73 65 72 74 65 64 2d 49 64 65 6e 74 69   -Asserted-Identi
      # ....
      # 0160  76 65 64 2d 55 73 65 72 3a 20 3c 73 69 70 3a 62   ved-User: <sip:b
      # The following code block displays the data in a human readable format
      if ((length($1) == 4) && ($1 != "Data")) {
        PAYLOAD = substr($0, 7, 50)
        L = split(PAYLOAD, CHARS, " ")
        for (i = 1; i <= L; i++) {
          dec = hex2dec(CHARS[i])
          printf "%c", dec > filename
        }
      }

    } else {
      print $0 > filename;
    }
  }
}
END {
  printf "  </pre>\n" >filename
  printf " </body>\n" >filename
  printf "</html>\n" >filename
  printf "\n" >filename
}

