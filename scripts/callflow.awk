

  print "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>";
  print "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.0//EN\" \"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd\">";

  for(i=0;i<numHosts;i++) {
    lookup[hosts[i]] = i;
    printf "<!-- lookup['%s'] = %d -->\n", hosts[i], i;
  }
  # Define the vertical distance between the node labels
  Z = 0;
  # Where the first line should start after node label
  Q = 0;
  w = (numHosts-1) * xHostSpace + leftMargin + rightMargin;
  h = numLines * yLineSpace + topMargin + bottomMargin;

  printf "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\">\n",w,h,w,h;

  insertStyleDefs();

  ystart = 60;
  yend = h;

  printf "<text x=\"%d\" y=\"%d\" class=\"label title-text\">%s</text>\n",
    (w/2),
    ystart-35,
    title;

  for(i=0;i<numTraces;i++) {

    if (label[i] == "")
      label[i] = hosts[i];

    printf "<text x=\"%d\" y=\"%d\" class=\"label host-text\">%s</text>\n",
      leftMargin+(i*xHostSpace),
      # Make the node labes inline
      ystart,
      label[i];

    printf "<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" class=\"element-line\" />\n", leftMargin+(i*xHostSpace), ystart, leftMargin+(i*xHostSpace), yend;
  }

  printf "   <map name=\"callflowmap\" id=\"callflowmap\">\n" > "imagemap";
}

func insertStyleDefs () {
  printf "<defs>\n<style type=\"text/css\"><![CDATA[\n";
  printf " .traceline { stroke-width: 1pt; stroke:black; }\n";
  printf " .pkt-text { color: red; font-family: Trebuchet MS,Helvetica, sans-serif;\n";
  printf "            font-size: 8pt; stroke: none; fill: black;}\n";
  printf " .comment-text { color: black; font-family: Trebuchet MS,Helvetica, sans-serif;\n";
  printf "            font-size: 9pt; stroke: none; fill: green;}\n";
  printf " .host-text { color: black; font-family: Trebuchet MS,Helvetica,sans-serif;\n";
  printf "             font-size: 10pt; stroke:none; fill:blue;}\n";
  printf " .title-text { color: black; font-family: Trebuchet MS,Helvetica,sans-serif;\n";
  printf "              font-size:16pt; stroke:none; fill:black;}\n";
  printf " .label { color: blue; text-anchor: middle ; }\n";
  printf " .arrowhead { stroke-width: 0.5pt;stroke:black; }\n";
  printf " .element-line { stroke-width: 0.25pt; stroke: black; }\n";
  printf " .link { color: blue; font-family: Trebuchet MS,Helvetica, sans-serif;\n";
  printf "		font-size: 9pt; text-decoration: underline; fill: blue;}\n";
  # printf " .session-text { color: red; font-family: Trebuchet MS,Helvetica, sans-serif;\n";
  # printf "		font-size: 9pt; font-weight: bold; fill: red;}\n";
  printf " ]]></style>\n</defs>\n";
}

func arrow(x,y,d,c) {
  
  printf "<polygon points=\"%d,%d %d,%d %d,%d %d,%d\" class=\"arrowhead\" style=\"fill: %s; stroke: %s;\"/>\n",
  x,y,
  x+5*d, y-3,
  x+3*d, y,
  x+5*d, y+3,
  color[c], color[c];
}

func line(x1,x2,y,output, c) {

  if (x1 == x2) {
    printf "<polyline points=\"%d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d\" fill=\"none\" class=\"traceline\" style=\"stroke: %s;\"/>\n",
      x1,y-18+7,
      x1+5,y-18+7,
      x1+12,y-15+7,
      x1+15,y-10+7,
      x1+15,y-5+7,
      x1+12,y-2+7,
      x1+5,y+7,
      x1,y+7,
      color[c];
    arrow(x1,y+7,1,c);

    xtext = x1 + 18;
    
    printf "    <area href=\"frames/Frame%d.html\" coords=\"%d,%d,%d,%d\" alt=\"frame %d\"  onmouseover=\"return getFrame('frames/Frame%d.html');\" onmouseout=\"return nd();\"/>\n", $3, x1, y-yLineSpace+2, x1+15, y+7+1, $3, $3 >> "imagemap"

  } else if (x1<x2) {
    printf "<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" class=\"traceline\" style=\"stroke: %s;\"/>\n", x1, y, x2, y, color[c];
    arrow(x2,y,-1,c);
  
    xtext = x1 + 10;
    
    printf "    <area href=\"frames/Frame%d.html\" coords=\"%d,%d,%d,%d\" alt=\"frame %d\"  onmouseover=\"return getFrame('frames/Frame%d.html');\" onmouseout=\"return nd();\"/>\n", $3, x1, y-yLineSpace+2, x2, y+1, $3, $3 >> "imagemap"

  } else {
    printf "<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" class=\"traceline\" style=\"stroke: %s;\"/>\n", x1, y, x2, y, color[c];
    arrow(x2,y,1,c);
    
    xtext = x2 + 10;
    
    printf "    <area href=\"frames/Frame%d.html\" coords=\"%d,%d,%d,%d\" alt=\"frame %d\"  onmouseover=\"return getFrame('frames/Frame%d.html');\" onmouseout=\"return nd();\"/>\n", $3, x2, y-yLineSpace+2, x1, y+1, $3, $3 >> "imagemap"
  }
  
  printf "<a href=\"frames/Frame%d.html\" target=\"_blank\">\n", $3;
  printf "<text x=\"%d\" y=\"%d\" class=\"pkt-text\">%s</text>\n", xtext, y-4, output;
  printf "</a>\n";
}

{ 
  y = NR;
  y = y * yLineSpace + ystart;
  y = y + (Q * 20);
  Z = Z + 1;
  # Insert Node labels after every 28th lines
  if ((Z % 28 == 1) && (Z != 1)){
    for(i=0;i<numTraces;i++) {
    if (label[i] == "")
      label[i] = hosts[i];
      printf "<text x=\"%d\" y=\"%d\" class=\"label host-text\">%s</text>\n",
      leftMargin+(i*xHostSpace),
      y,
      label[i];
    }
    y = y + 20;
    Q = Q + 1;
  }
  if ($0 ~ "^#") {

    # The "!" is the link identifier
    LINK = index($0, "!")
    if (LINK == 0) {
      # There is no link, everything behind the first "#" is the comment
      sub("#", "", $0)
      printf("<text x=\"%d\" y=\"%d\" class=\"comment-text\" xml:space=\"preserve\">%s</text>\n", leftMargin + 5, y, $0);

    } else {
      # Make the comment a hyperlink
      # - Everything before the "!" is the link text
      # - Everything behind the "!" is the hyperlink
      output = substr($0, 2, LINK - 2)
      link = substr($0, LINK + 1)

      printf("<text x=\"%d\" y=\"%d\" class=\"link\" xml:space=\"preserve\">%s</text>\n", leftMargin + 5, y, output);
      printf("    <area href=\"%s\" coords=\"%d,%d,%d,%d\"/>\n", link, leftMargin + 5, y-yLineSpace+2, w, y+1) >> "imagemap";
    }

  } else {

    if ($6 ~ "{([0-9]+)}") {
      str = $6
      gsub("{", "", str)
      gsub("}", "", str)
    
      colorId = strtonum(str)
      if ( colorId <= colors ) {
        c = colorId
      } else {

        # There are more sessions than configured colors.
        # choose the first color as default...
        c = 0
      }

    } else { c = 0 }

    l1 = sprintf("%s:%s", $4,$5);
    l2 = sprintf("%s:%s", $7,$8);
    for (i=0; i<numHosts; i++) {

      if (l1 ~ hosts[i]) {
        x1 = strtonum(lookup[hosts[i]]);
      }

      if (l2 ~ hosts[i]) {
        x2 = strtonum(lookup[hosts[i]]);
      }
    }

    x1 = x1 * xHostSpace + leftMargin;
    x2 = x2 * xHostSpace + leftMargin;
    if ((x1==x2) && (localLoop == 0)) {
      # Do nothing
    } else {
      # Print the line
      ORS = "";
      printf ("<text x=\"%d\" y=\"%d\" class=\"pkt-text\" xml:space=\"preserve\" ", leftMargin - 10, y)
      printf ("style=\"text-anchor: end;\">%d", $3)
      if ( showTime == "yes" ) {
        printf ("    %s", $1)
      }
      printf ("</text>\n")

      if ((showSDP == "yes") && ($9 ~ "SDP")) {
        output = sprintf("%s: a=%s:%s %s %s", $10, $12, $13, $14, $15)
      } else {
        output = $10
      }

      line(x1, x2, y, output, c);
    }
  }
}

END {
  printf "   </map>\n" >> "imagemap";
  printf "</svg>\n";
}

