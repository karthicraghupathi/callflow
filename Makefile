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
DESTDIR ?= $(prefix)

# Callflow personnal variables. SETUPDIR is used for DEBIAN packages
PROGDIR ?= /callflow
SETUPDIR ?= $(DESTDIR)$(PROGDIR)
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
	
	#Change CONFDIR variable with $(CONFDIR) into $(bindir)/callflow
	@$(SED) "s#/etc/callflow#$(CONFDIR)#" $(bindir)/callflow
	
	#Change SETUPDIR variable with $(SETUPDIR) into $(CONFDIR)/callflow.cfg
	@$(SED) "s#/usr/local/callflow#$(SETUPDIR)#" $(CONFDIR)/callflow.cfg
	
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


