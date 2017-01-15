

  print "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>";
  print "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.0//EN\" \"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd\">";

  longNames = "no"

  # A character takes on average between 6-7 pixels (dots).  When 7 is used a lot of 
  # node name space is offered to prevent overlapping node names.  When 6 pixels are used
  # a little overlap occurs at the boundary of activating the camel pattern.  In this
  # case it is up to user to play with --width-between-nodes value to prevent overlapping
  # name labels or use shorter node names.
  maxCharsForName = int ( xHostSpace / 6 )

  for(i=0;i<numHosts;i++) {
    lookup[hosts[i]] = i;
    printf "<!-- lookup['%s'] = %d -->\n", hosts[i], i;
    if ((camelcase == "always") || (length(label[i]) > maxCharsForName))
      longNames = "yes";
  }

  nodes_extra_height = ( int(numLines / yLinesBetweenNodes) + 1 ) * yHostNameSpace
  if (longNames == "yes") {
    # Take the camel pattern into account when the node names are long
    nodes_extra_height *= 2 
  }

  w = (numHosts-1) * xHostSpace + leftMargin + rightMargin;
  h = numLines * yLineSpace + topMargin + bottomMargin + nodes_extra_height;
  yend = h;
  printf "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\">\n", w, h, w, h

  # Info for debugging
  debug = 0
  if (debug) {
    printf "<!--\n"
    printf "  DEBUG: == Set Values ==\n"
    printf "  DEBUG: topMargin = %d\n", topMargin
    printf "  DEBUG: bottomMargin = %d\n", bottomMargin
    printf "  DEBUG: rightMargin = %d\n", rightMargin
    printf "  DEBUG: leftMargin = %d\n", leftMargin
    printf "  DEBUG: xHostSpace = %d\n", xHostSpace
    printf "  DEBUG: yLineSpace = %d\n", yLineSpace
    printf "  DEBUG: yLinesBetweenNodes = %d\n", yLinesBetweenNodes
    printf "  DEBUG: \n" 
    printf "  DEBUG: == Calculated Values ==\n"
    printf "  DEBUG: maxCharsForName = %d\n", maxCharsForName;
    printf "  DEBUG: numlines = %d\n", numLines
    printf "  DEBUG: Extra inline node name lines = %d\n", int(numLines / yLinesBetweenNodes)
    printf "  DEBUG: nodes_extra_height = %d\n", nodes_extra_height
    printf "  DEBUG: yHostNameSpace = %d\n", yHostNameSpace
    printf "  DEBUG: Height = %d\n", h
    printf "  DEBUG: Width = %d\n", w
    printf "-->\n\n"

    # The actual size of the drawing can be obtained by executed the following
    # shell script in the data directory.
    # ( grep -E "<polygon" $DESTDIR/callflow.svg |
    #     awk -F\" '{print $2}' | awk -F, '{print $NF}' 
    # 
    #   grep -E "<line|<text" callflow-dir/callflow.svg |
    #     awk '{print $3}' | cut -d\" -f2
    # 
    # ) | sort -n | tail -1
  }

  insertStyleDefs();

  y = 25;

  # With 'leftMargin + ( 1.5 * xHostSpace )' the title is centered above
  # the second column
  printf "<text x=\"%d\" y=\"%d\" class=\"label title-text\">%s</text>\n",
    leftMargin + ( 1.5 * xHostSpace ),
    y,
    title;

  y += yHostNameSpace

  # Take the camel pattern into account in case the node names are long
  if (longNames == "yes") {
    y += yHostNameSpace
  }

  # 1: print the vertical node lines
  print_nodes(y, 1);

  printf "   <map name=\"callflowmap\" id=\"callflowmap\">\n" > imageMap;
}


################ Fuction Definition  ##################

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
    
    printf "    <area href=\"frames/Frame%d.html\" coords=\"%d,%d,%d,%d\" alt=\"frame %d\"  onmouseover=\"return getFrame('frames/Frame%d.html');\" onmouseout=\"return nd();\"/>\n", $3, x1, y-yLineSpace+2, x1+15, y+7+1, $3, $3 >> imageMap

  } else if (x1<x2) {
    printf "<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" class=\"traceline\" style=\"stroke: %s;\"/>\n", x1, y, x2, y, color[c];
    arrow(x2,y,-1,c);
  
    xtext = x1 + 10;
    
    printf "    <area href=\"frames/Frame%d.html\" coords=\"%d,%d,%d,%d\" alt=\"frame %d\"  onmouseover=\"return getFrame('frames/Frame%d.html');\" onmouseout=\"return nd();\"/>\n", $3, x1, y-yLineSpace+2, x2, y+1, $3, $3 >> imageMap

  } else {
    printf "<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" class=\"traceline\" style=\"stroke: %s;\"/>\n", x1, y, x2, y, color[c];
    arrow(x2,y,1,c);
    
    xtext = x2 + 10;
    
    printf "    <area href=\"frames/Frame%d.html\" coords=\"%d,%d,%d,%d\" alt=\"frame %d\"  onmouseover=\"return getFrame('frames/Frame%d.html');\" onmouseout=\"return nd();\"/>\n", $3, x2, y-yLineSpace+2, x1, y+1, $3, $3 >> imageMap
  }
  
  printf "<a href=\"frames/Frame%d.html\" target=\"_blank\">\n", $3;
  printf "<text x=\"%d\" y=\"%d\" class=\"pkt-text\">%s</text>\n", xtext, y-4, output;
  printf "</a>\n";
}

func print_nodes(yPos, first_line) {
  for(i=0;i<numTraces;i++) {

    if (label[i] == "")
      label[i] = hosts[i];

    #  Display the node names in a camel case (low-high) pattern when longNames == yes
    if (longNames == "yes") {
       adjustment = yHostNameSpace*(i%2)
    }

    printf "<text x=\"%d\" y=\"%d\" class=\"label host-text\">%s</text>\n",
      leftMargin+(i*xHostSpace),
      yPos-adjustment,
      label[i];

    # Drawing the lines for the actors only needed once
    if (first_line){
      printf "<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" class=\"element-line\" />\n", leftMargin+(i*xHostSpace), yPos+2, leftMargin+(i*xHostSpace), yend;
    }
  }
}

################ Main ##################
{
  if ( NR % yLinesBetweenNodes == 0 ) {

    y += yHostNameSpace

    if ( longNames == "yes" ) {
      y += yHostNameSpace
    } 

    # 0: only print the node names
    print_nodes(y, 0)
  }

  y += yLineSpace

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
      printf("    <area href=\"%s\" coords=\"%d,%d,%d,%d\"/>\n", link, leftMargin + 5, y-yLineSpace+2, w, y+1) >> imageMap;
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
  printf "   </map>\n" >> imageMap;
  printf "</svg>\n";
}

