BEGIN{
  first = 1;
}

/^Frame [0-9]+: (.*)/ {
  # New frame, closing <pre> and html> from previous frame before compute new filename
  if (first == 0) {
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
  # Print time
  getline
  gsub("^ *", "")
  print $0 >filename;
  discard = 1;
}
/^Internet Protocol,/ {
  print $0 >filename;
  discard = 1;
}
/^Internet Protocol$/ {
  discard = 0;
}
/^User Datagram Protocol,/ {
  print $0 >filename;
  discard = 1;
}
/^User Datagram Protocol$/ {
  discard = 0;
}
/^Transmission Control Protocol,/ {
  print $0 >filename;
  discard = 1;
}
/^Transmission Control Protocol$/ {
  discard = 0;
}
/^Internet Control Message Protocol/ {
  discard = 0;
}
/^Session Initiation Protocol/ {
  discard = 0;
}
/^Diameter Protocol/ {
  discard = 0;
}
/^WebSocket Protocol/ {
  discard = 0;
}
/^Hypertext Transfer Protocol/ {
  discard = 0;
}
/^Call Specification Language/ {
  discard = 0;
}
{
  if (discard==0)
    {
      
      gsub("&","\\&amp;");
      gsub(">","\\&gt;");
      gsub("<","\\&lt;");

      MARK = "no"
      if ($0 ~ "Session Initiation Protocol" ) MARK = "sip"
      if ($1 ~ "Accept:" ) MARK = "sip"
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
      if ($1 ~ "From:" ) MARK = "sip"
      if ($1 ~ "P-[A-Z][a-z].*:" ) MARK = "sip"
      if ($1 ~ "Privacy:" ) MARK = "sip"
      if ($1 ~ "RAck:" ) MARK = "sip"
      if ($1 ~ "Remote-Party-ID:" ) MARK = "sip"
      if ($1 ~ "Require:" ) MARK = "sip"
      if ($1 ~ "Request-Line:" ) MARK = "sip"
      if ($1 ~ "Route:" ) MARK = "sip"
      if ($1 ~ "RSeq:" ) MARK = "sip"
      if ($1 ~ "Server:" ) MARK = "sip"
      if ($1 ~ "Supported:" ) MARK = "sip"
      if ($1 ~ "Timestamp:" ) MARK = "sip"
      if ($1 ~ "To:" ) MARK = "sip"
      if ($1 ~ "User-Agent:" ) MARK = "sip"
      if ($1 ~ "Via:" ) MARK = "sip"

      if ($0 ~ "Session Description Protocol") MARK = "media"
      if ($0 ~ "Connection Information") MARK = "media"
      # Use ... here.  Actually "(a)" should be used, but awk does not like the
      # parenthesis (), workaround it with the dots.
      if ($0 ~ "Media Attribute ...:") MARK = "media"
      if ($0 ~ "Media Description, name and address") MARK = "media"
      if ($0 ~ "Owner/Creator, Session Id") MARK = "media"
      if ($0 ~ "Session Attribute ...:") MARK = "media"
      if ($0 ~ "Session Description Protocol Version") MARK = "media"
      if ($0 ~ "Session Name") MARK = "media"
      if ($0 ~ "Time Description, active time") MARK = "media"

      if (MARK == "sip") {
        printf "<div class=\"sip\">%s</div>\n", $0 > filename;

      } else if (MARK == "media") {
        printf "<div class=\"media\">%s</div>\n", $0 > filename;

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

