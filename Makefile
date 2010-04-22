###  Makefile

#Binaries
ECHO ?= echo
INSTALL ?= install
UNINSTALL ?= rm -rf
MKDIR ?= mkdir -p
SED ?= sed -i -e

#Variables
prefix ?= /usr/local
exec_prefix ?= $(prefix)
bindir ?= $(exec_prefix)/bin
DESTDIR ?= $(prefix)
PROGDIR ?= /callflow

.PHONY: install uninstall

install:
	#Copy files into $(DESTDIR)$(PROGDIR)
	@$(MKDIR) $(DESTDIR)$(PROGDIR)
	@$(MKDIR) $(DESTDIR)$(PROGDIR)/awk-scripts
	@$(MKDIR) $(DESTDIR)$(PROGDIR)/js
	@$(INSTALL) awk-scripts/* $(DESTDIR)$(PROGDIR)/awk-scripts
	@$(INSTALL) js/* -m 644 $(DESTDIR)$(PROGDIR)/js
	@$(INSTALL) -m 644 AUTHORS $(DESTDIR)$(PROGDIR)/AUTHORS
	@$(INSTALL) -m 644 README $(DESTDIR)$(PROGDIR)/
	@$(INSTALL) -m 644 LICENSE $(DESTDIR)$(PROGDIR)/
	
	#Install callflow bin into $(DESTDIR)/bin/ directory
	@$(INSTALL) -m 755 callflow $(bindir)/
	
	#Change __SETUPDIR__ variable with $(DESTDIR)$(PROGDIR)
	@$(SED) "s;__SETUPDIR__;$(DESTDIR)$(PROGDIR);" $(bindir)/callflow
	
	# --> DONE !
	
uninstall:
	#Remove directory $(DESTDIR)$(PROGDIR)
	@$(UNINSTALL) $(DESTDIR)$(PROGDIR) 2>&1
	
	#Remove callflow from $(bindir)
	@$(UNINSTALL) $(bindir)/callflow 2>&1
	
	# --> DONE !

