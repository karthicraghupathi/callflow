###  Makefile

.PHONY: install uninstall

install:
	#Copy files into /usr/share/callflow
	@mkdir -p /usr/share/callflow
	@cp -a awk-scripts/ /usr/share/callflow/
	@cp -a batik/ /usr/share/callflow/
	@cp -a callflow /usr/share/callflow/
	@cp -a AUTHORS /usr/share/callflow/
	@cp -a README /usr/share/callflow/
	@cp -a LICENSE /usr/share/callflow/
	
	#Create symlinks for callflow into /usr/bin
	@ln -s /usr/share/callflow/callflow /usr/bin/callflow
	
	# --> DONE !
	
uninstall:
	#Remove directory /usr/share/callflow
	@rm -rf /usr/share/callflow
	
	#Remove symlinks
	@rm -f /usr/bin/callflow
	
	# --> DONE !

