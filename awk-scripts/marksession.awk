BEGIN {
   session_count = 0;
}

{
   if ($1 ~ "[0-9]+") {
	  /* See if the current line is already in the table */
	  frame_file = destDir "/frames/Frame"$1".html";
	  "grep -i \"" session_token "\" " frame_file | getline session_line;
	  found = 0;
	  split(session_line, array);
	  session = array[2];

	  for (i=0; i < session_count; i++) {
		 if (sessions[i] == session) {
			found = 1;
			$4 = "{" i+1 "}";
			print $0;
			break;
		 }
	  }
	  if (found == 0) {
		 $4 = "{" session_count+1 "}";
		 sessions[session_count++] = session;
		 print $0;
		 s = sprintf("echo 'New session in frame %s: %s' >&2", $1, session);
		 system(s);
	  }

   } else {
	  print $0;
   }
}
