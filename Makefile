###  Makefile

.PHONY: install uninstall

install:
	#Copy files into /usr/share/callflow
	@mkdir -p $(basedir)/usr/share/callflow
	@cp -a awk-scripts/ $(basedir)/usr/share/callflow/
	@cp -a batik/ $(basedir)/usr/share/callflow/
	@cp -a callflow $(basedir)/usr/share/callflow/
	@cp -a AUTHORS $(basedir)/usr/share/callflow/
	@cp -a README $(basedir)/usr/share/callflow/
	@cp -a LICENSE $(basedir)/usr/share/callflow/
	
	#Create symlinks for callflow into /usr/bin
	@-ln -s $(basedir)/usr/share/callflow/callflow $(basedir)/usr/bin/callflow 2>&1
	
	# --> DONE !
	
uninstall:
	#Remove directory /usr/share/callflow
	@rm -rf $(basedir)/usr/share/callflow 2>&1
	
	#Remove symlinks
	@rm -f $(basedir)/usr/bin/callflow 2>&1
	
	# --> DONE !

