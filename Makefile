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
mandir ?= $(prefix)/share/man
man1dir ?= $(mandir)/man1

DESTDIR ?= $(prefix)
PROGDIR ?= /callflow
CONFDIR ?= /etc/callflow

.PHONY: install uninstall

clean:
	#Nothing to do
	
install: install_man install_conf
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
	
	#Change __CONFDIR__ variable with $(CONFDIR)
	@$(SED) "s;__CONFDIR__;$(CONFDIR);" $(bindir)/callflow
	
	# --> DONE !

install_man:
	#Install man page
	@$(MKDIR) $(man1dir)
	@$(INSTALL) -m 644 man/callflow.1.gz $(man1dir)/callflow.1.gz
	
install_conf:
	#Install conf files
	@$(MKDIR) $(CONFDIR)
	@$(INSTALL) -m 644 conf/callflow.cfg $(CONFDIR)/callflow.cfg

uninstall:
	#Remove directory $(DESTDIR)$(PROGDIR)
	@$(UNINSTALL) $(DESTDIR)$(PROGDIR) 2>&1
	
	#Remove callflow from $(bindir)
	@$(UNINSTALL) $(bindir)/callflow 2>&1
	
	#Remove man page
	@$(UNINSTALL) $(man1dir)/callflow.1.gz
	
	#Remove conf files
	@$(UNINSTALL) $(CONFDIR)
	
	# --> DONE !


