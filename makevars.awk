BEGIN {
  print "BEGIN {";
  print "  numHosts=0;";
}


{
  printf "label[numHosts] = \"";
  for (i=2; i<=NF; i++)
    {
      printf "%s", $i;
      if (i != NF)
        printf " ";
    }
  printf "\";\n"
  printf "hosts[numHosts++] = \"%s\";", $1;
}
