BEGIN{
  first=1;
}
#/^Frame [0-9]+/ {
#  filename = destDir "/frames/Frame" $2 ".html";
#  printf "<html>\n" >filename;
#  printf "<pre>\n" >filename;
#  discard = 0;
#}
/^Frame [0-9]+ (.*)/ {
  # New frame, closing <pre> and html> from previous frame before compute new filename
  if (first==0){
    print "</pre></html>" >filename;
  }
  else{
    first=0;
  }
  filename = destDir "/frames/Frame" $2 ".html";
  printf "<html>\n" >filename;
  printf "<pre>\n" >filename;
  print $0 >filename;
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
      print $0 > filename;
    }
}
END {
  print "</pre></html>" >filename
}
