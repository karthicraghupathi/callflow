BEGIN {
   seen_count = 0;
}
{
   discard = 0;
   if ($1 ~ "[0-9]") {
	  seen[seen_count] = $1

	  for (i = seen_count-1; i >= 0; --i) {
		 file1 = destDir "/frames/Frame" $1 ".html"
		 file2 = destDir "/frames/Frame" seen[i] ".html"
		 diff_cmd = sprintf("diff -s --brief -I \"Arrival Time\" -I \"Frame [:digit:]*\" -I \"Resent Packet\" -I \"Suspected resend of frame\" %s %s > /dev/null", file1, file2);
		 if (system(diff_cmd) == 0) {
			report_dup = sprintf("echo '%s is identical to %s' 1>&2", file1, file2);
			system(report_dup);
			discard = 1;
			break;
		 }
	  }
	  seen_count++;
   }

   if (discard == 0) {
	  print $0;
   }
}
