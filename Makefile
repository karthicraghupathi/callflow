###  Makefile

.PHONY: callflow all

install: callflow

callflow:
	#Copy files into /usr/share/callflow
	mkdir -p /usr/share/callflow
	cp -a awk-scripts/ /usr/share/callflow/
	cp -a batik/ /usr/share/callflow/
	cp -a callflow /usr/share/callflow/
	cp -a AUTHORS /usr/share/callflow/
	cp -a README /usr/share/callflow/
	cp -a LICENCE /usr/share/callflow/
	
	#Create symlinks for callflow into /usr/bin
	ln -s /usr/share/callflow/callflow /usr/bin/callflow

