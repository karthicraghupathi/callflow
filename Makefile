###  Makefile

#Binaries
ECHO ?= echo
INSTALL ?= install
UNINSTALL ?= rm -rf
MKDIR ?= mkdir -p
SED ?= sed -i -e
GZIP ?= gzip

# GNU respectfull variables
prefix ?= /usr/local
exec_prefix ?= $(prefix)
bindir ?= $(exec_prefix)/bin
mandir ?= $(prefix)/share/man
man1dir ?= $(mandir)/man1

# DESTDIR (used for Debian packaging)
DESTDIR ?= 

# Callflow personnal variables
PROGDIR ?= $(prefix)/share/callflow
CONFDIR ?= /etc/callflow

.PHONY: install uninstall

clean:
	#Nothing to do
	
install: install_man install_conf
	#Copy files
	@$(MKDIR) $(DESTDIR)$(PROGDIR)
	@$(MKDIR) $(DESTDIR)$(PROGDIR)/scripts
	@$(MKDIR) $(DESTDIR)$(PROGDIR)/js
	@$(MKDIR) $(DESTDIR)$(bindir)
	@$(INSTALL) -m 644 scripts/* $(DESTDIR)$(PROGDIR)/scripts
	@$(INSTALL) -m 755 scripts/removedups.sh $(DESTDIR)$(PROGDIR)/scripts
	@$(INSTALL) js/* -m 644 $(DESTDIR)$(PROGDIR)/js
	@$(INSTALL) -m 644 AUTHORS $(DESTDIR)$(PROGDIR)/AUTHORS
	@$(INSTALL) -m 644 README $(DESTDIR)$(PROGDIR)/
	@$(INSTALL) -m 644 LICENSE $(DESTDIR)$(PROGDIR)/
	
	#Install callflow bin into $(DESTDIR)$(bindir)/ directory
	@$(INSTALL) -m 755 callflow $(DESTDIR)$(bindir)/
	
	#Change CONFDIR variable with $(CONFDIR) into $(bindir)/callflow
	@$(SED) "s#/etc/callflow#$(CONFDIR)#" $(DESTDIR)$(bindir)/callflow
	
	# --> DONE !

install_man:
	#Install man page
	@$(MKDIR) $(DESTDIR)$(man1dir)
	@$(INSTALL) -m 644 man/callflow.1 $(DESTDIR)$(man1dir)/callflow.1
	@$(GZIP) $(DESTDIR)$(man1dir)/callflow.1
	
install_conf:
	#Install conf files
	@$(MKDIR) $(DESTDIR)$(CONFDIR)
	@$(INSTALL) -m 644 conf/* $(DESTDIR)$(CONFDIR)
	
	#Change SETUPDIR variable with $(PROGDIR) into $(CONFDIR)/callflow.conf
	@$(SED) "s#/usr/local/callflow#$(PROGDIR)#" $(DESTDIR)$(CONFDIR)/callflow.conf

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


