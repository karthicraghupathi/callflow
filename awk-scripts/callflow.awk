  yLineSpace = 24;
  xHostSpace = 200;
  leftMargin = 100;
  rightMargin = 100;
  topMargin = 50;
  bottomMargin = 50;
  numTraces = numHosts;

  color[0]  = "black";
  color[1]  = "orange";
  color[2]  = "sienna";
  color[3]  = "red";
  color[4]  = "green";
  color[5]  = "purple";
  color[6]  = "chocolate";
  color[7]  = "olivedrab";
  color[8]  = "darkred";
  color[9]  = "darkslategrey";
  color[10] = "MidnightBlue";
  color[11] = "maroon";

  print "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>";
  print "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.0//EN\" \"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd\">";

  for(i=0;i<numHosts;i++) {
    lookup[hosts[i]] = i;
    printf "<!-- lookup['%s'] = %d -->\n", hosts[i], i;
  }

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
      ystart-(15*(i%2)+2),
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
  printf "            font-size: 9pt; font-style: italic; stroke: none; fill: green;}\n";
  printf " .host-text { color: black; font-family: Trebuchet MS,Helvetica,sans-serif;\n";
  printf "             font-size: 10pt; stroke:none; fill:blue;}\n";
  printf " .title-text { color: black; font-family: Trebuchet MS,Helvetica,sans-serif;\n";
  printf "              font-size:16pt; stroke:none; fill:black;}\n";
  printf " .label { color: blue; text-anchor: middle ; }\n";
  printf " .arrowhead { stroke-width: 0.5pt;stroke:black; }\n";
  printf " .element-line { stroke-width: 0.25pt; stroke: black; }\n";
  printf " .link { color: blue; font-family: Trebuchet MS,Helvetica, sans-serif;\n";
  printf "		font-size: 9pt; text-decoration: underline; fill: blue;}\n";
  printf " .session-text { color: red; font-family: Trebuchet MS,Helvetica, sans-serif;\n";
  printf "		font-size: 9pt; font-weight: bold; fill: red;}\n";
  printf " ]]></style>\n</defs>\n";
}

func arrow(x,y,d,c) {
  
  printf "<polygon points=\"%d,%d %d,%d %d,%d %d,%d\" class=\"arrowhead\" style=\"fill: %s; stroke: %s\"/>\n",
  x,y,
  x+5*d, y-3,
  x+3*d, y,
  x+5*d, y+3,
  color[c], color[c];
}

func line(x1,x2,y,output, c) {

  if (x1 == x2) {
    printf "<polyline points=\"%d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d\" fill=\"none\" class=\"traceline\"/>\n",
      x1,y-18+7,
      x1+5,y-18+7,
      x1+12,y-15+7,
      x1+15,y-10+7,
      x1+15,y-5+7,
      x1+12,y-2+7,
      x1+5,y+7,
      x1,y+7;
    arrow(x1,y+7,1);

    xtext = x1 + 18;
    
    printf "    <area href=\"frames/Frame%d.html\" coords=\"%d,%d,%d,%d\" alt=\"frame %d\"/>\n", $1, x1, y-yLineSpace+2, x1+15, y+7+1, $1 >> "imagemap"

  } else if (x1<x2) {
    printf "<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" class=\"traceline\" style=\"stroke: %s\"/>\n", x1, y, x2, y, color[c];
    arrow(x2,y,-1,c);
  
    xtext = x1 + 10;
    
    printf "    <area href=\"frames/Frame%d.html\" coords=\"%d,%d,%d,%d\" alt=\"frame %d\"/>\n", $1, x1, y-yLineSpace+2, x2, y+1, $1 >> "imagemap"

  } else {
    printf "<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" class=\"traceline\" style=\"stroke: %s\"/>\n", x1, y, x2, y, color[c];
    arrow(x2,y,1,c);
    
    xtext = x2 + 10;
    
    printf "    <area href=\"frames/Frame%d.html\" coords=\"%d,%d,%d,%d\" alt=\"frame %d\"/>\n", $1, x2, y-yLineSpace+2, x1, y+1, $1 >> "imagemap"
  }
  
  printf "<a href=\"frames/Frame%d.html\" target=\"_blank\">\n", $1;
  printf "<text x=\"%d\" y=\"%d\" class=\"pkt-text\">%s</text>\n", xtext, y-4, output;
  printf "</a>\n";
}

{ 
  y = NR;
  y = y * yLineSpace + ystart;

  if($1 == "#")
  {
	 output = "";
	 for (i=2; i<=NF; i++)
	 {
		if ($i == "!")
		   break;
		output = output " " $i;
	 }

	 link = "";
	 if($i == "!")
	 {
		i++;
		for(;i<=NF;i++)
		{
		   link = link " " $i;
		}
	 }

	 if (link != "")
	 {
		printf("<text x=\"%d\" y=\"%d\" class=\"link\">%s</text>\n", 50, y, output);
		printf("    <area href=\"%s\" coords=\"%d,%d,%d,%d\"/>\n", link, 50, y-yLineSpace+2, w, y+1) >> "imagemap";
	 }
	 else
	 {
		printf("<text x=\"%d\" y=\"%d\" class=\"comment-text\">%s</text>\n", 50, y, output);
	 }
  }
  else
  {
	 if ($4 ~ "{([0-9]+)}") {
		c = $4
		gsub("{", "", c)
		gsub("}", "", c)
		
		# If over 11 colors, choose black color as default...
		# TODO: change color behavior
		if (strtonum(c)>11) {c="0"}
		# printf("<text x=\"%d\" y=\"%d\" class=\"session-text\" style=\"fill: %s;\">%s</text>\n", 25, y, color[c], $4);
	 }
	 l1 = sprintf("%s:%s", $2,$3);
	 l2 = sprintf("%s:%s", $5,$6);
	 for (i=0; i<numHosts; i++)
	 {
	   if(l1 ~ hosts[i])
	   {
		 x1 = strtonum(lookup[hosts[i]]);
	   }
	   if(l2 ~ hosts[i])
	   {
		 x2 = strtonum(lookup[hosts[i]]);
	   }
	 }

	 x1 = x1 * xHostSpace + leftMargin;
	 x2 = x2 * xHostSpace + leftMargin;

	 ORS = "";
	 printf "<text x=\"%d\" y=\"%d\" class=\"pkt-text\" style=\"fill: %s;\">%d</text>\n", leftMargin/2, y, color[c], $1;

	 output = "";
	 for(i=7;i<=NF;i++) output = output " " $i;

	 gsub("SIP(/SDP|/XML|) *(Status|Request): *","", output);
	 gsub(", with session description *$"," w/SDP",output);
	if ((x1==x2) && (noAuto==1)){
		}
	else{
		line(x1,x2,y,output,c);
		}
  }
}


END {
  printf "   </map>\n" >> "imagemap";
  printf "</svg>\n";
}
