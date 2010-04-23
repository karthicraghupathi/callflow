###  Makefile

#Binaries
ECHO ?= echo
INSTALL ?= install
UNINSTALL ?= rm -rf
MKDIR ?= mkdir -p
SED ?= sed -i -e

# GNU respectfull variables
prefix ?= /usr/local
exec_prefix ?= $(prefix)
bindir ?= $(exec_prefix)/bin
mandir ?= $(prefix)/share/man
man1dir ?= $(mandir)/man1

# DESTDIR
DESTDIR ?= 

# Callflow personnal variables
PROGDIR ?= /callflow
CONFDIR ?= /etc/callflow

.PHONY: install uninstall

clean:
	#Nothing to do
	
install: install_man install_conf
	#Copy files
	@$(MKDIR) $(DESTDIR)$(prefix)$(PROGDIR)
	@$(MKDIR) $(DESTDIR)$(prefix)$(PROGDIR)/awk-scripts
	@$(MKDIR) $(DESTDIR)$(prefix)$(PROGDIR)/js
	@$(MKDIR) $(DESTDIR)$(bindir)
	@$(INSTALL) awk-scripts/* $(DESTDIR)$(prefix)$(PROGDIR)/awk-scripts
	@$(INSTALL) js/* -m 644 $(DESTDIR)$(prefix)$(PROGDIR)/js
	@$(INSTALL) -m 644 AUTHORS $(DESTDIR)$(prefix)$(PROGDIR)/AUTHORS
	@$(INSTALL) -m 644 README $(DESTDIR)$(prefix)$(PROGDIR)/
	@$(INSTALL) -m 644 LICENSE $(DESTDIR)$(prefix)$(PROGDIR)/
	
	#Install callflow bin into $(DESTDIR)$(bindir)/ directory
	@$(INSTALL) -m 755 callflow $(DESTDIR)$(bindir)/
	
	#Change CONFDIR variable with $(CONFDIR) into $(bindir)/callflow
	@$(SED) "s#/etc/callflow#$(CONFDIR)#" $(DESTDIR)$(bindir)/callflow
	
	# --> DONE !

install_man:
	#Install man page
	@$(MKDIR) $(DESTDIR)$(man1dir)
	@$(INSTALL) -m 644 man/callflow.1.gz $(DESTDIR)$(man1dir)/callflow.1.gz
	
install_conf:
	#Install conf files
	@$(MKDIR) $(DESTDIR)$(CONFDIR)
	@$(INSTALL) -m 644 conf/callflow.cfg $(DESTDIR)$(CONFDIR)/callflow.cfg
	
	#Change SETUPDIR variable with $(prefix)$(PROGDIR) into $(CONFDIR)/callflow.cfg
	@$(SED) "s#/usr/local/callflow#$(prefix)$(PROGDIR)#" $(DESTDIR)$(CONFDIR)/callflow.cfg

uninstall:
	#Remove directory $(DESTDIR)$(PROGDIR)
	@$(UNINSTALL) $(DESTDIR)$(PROGDIR)
	
	#Remove callflow from $(bindir)
	@$(UNINSTALL) $(DESTDIR)$(bindir)/callflow
	
	#Remove man page
	@$(UNINSTALL) $(DESTDIR)$(man1dir)/callflow.1.gz
	
	#Remove conf files
	@$(UNINSTALL) $(DESTDIR)$(CONFDIR)
	
	# --> DONE !


