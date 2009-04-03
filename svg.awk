BEGIN {
  lookup["192.168.8.104"] = "1";
  lookup["192.168.8.162"] = "2";
  lookup["192.168.8.103"] = "5";
  lookup["192.168.8.108"] = "4";
  lookup["192.168.8.201"] = "3";
  lookup["192.168.8.110"] = "6";
  lookup["192.168.8.106"] = "7";

  print "<?xml version='1.0'?>";
  print "<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.0//EN'";
  print "'http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd'>";
  
  width = (Nodes + 2) * 100;
  height = (Lines * 10) + 30;

  printf "<svg width='%d' height='%d' viewBox='0 0 800 1000'>\n", width, height;

  ystart = 20;
  yend = ystart + Lines * 10;

  for (i=0; i<Nodes; i++)
    {
      printf "<line x1='%d' y1='%d' x2='%d' y2='%d' />", 100+(i*100), ystart, 100+(i*100), yend;
    }

   
}
{ 
  y = strtonum($1);
  y = y * 30;

  x1 = strtonum(lookup[$3]);
  x2 = strtonum(lookup[$5]);

  x1 = x1 * 100;
  x2 = x2 * 100;

  ORS = "";
  printf "<line x1='%d' y1='%d' x2='%d' y2='%d' style='stroke:black' />\n", x1, y, x2, y;

  if (x1 < x2)
    {
      printf "<line x1='%d' y1='%d' x2='%d' y2='%d' style='stroke:black;stroke-opacity: 1.0; stroke-width: 1;' />\n", x2, y, x2-5, y-5;
      printf "<line x1='%d' y1='%d' x2='%d' y2='%d' style='stroke:black;stroke-opacity: 1.0; stroke-width: 1;' />\n", x2, y, x2-5, y+5;
    }
  else
    {
      printf "<line x1='%d' y1='%d' x2='%d' y2='%d' style='stroke:black;stroke-opacity: 1.0; stroke-width: 1;' />\n", x2, y, x2+5, y-5;
      printf "<line x1='%d' y1='%d' x2='%d' y2='%d' style='stroke:black;stroke-opacity: 1.0; stroke-width: 1;' />\n", x2, y, x2+5, y+5;
    }
  if (x1<x2)
    xtext = x1 + 10;
  else
    xtext = x2 + 10;

  printf "<text x='%d' y='%d' style='font-family:sans-serif; font-size: 8pt; stroke: none; fill: black;'>%s %s %s %s</text>\n", xtext, y-4, $6, $7, $8, $9;
}


END {
  print "</svg>\n"
    }
