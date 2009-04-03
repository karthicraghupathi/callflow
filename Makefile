###  Set the following variable to the location of batik-1.5beta3 on your system
###  batik-1.5beta3 can be obtained from 
###         http://xml.apache.org/batik/dist/batik-1.5beta3.zip

BATIK_LOCATION = /home/eringlej/batik-1.5

FILES=callflow.awk callflow.sh getnodes getnodes.awk long2html.awk makevars.awk svg.awk wc.awk prunenodes.awk removedups.awk marksession.awk \
batik/batik-rasterizer.jar \
batik/lib/batik-awt-util.jar \
batik/lib/batik-dom.jar \
batik/lib/batik-gui-util.jar \
batik/lib/batik-script.jar  \
batik/lib/batik-transcoder.jar  \
batik/lib/crimson-parser.jar \
batik/lib/batik-bridge.jar   \
batik/lib/batik-extension.jar \
batik/lib/batik-gvt.jar      \
batik/lib/batik-svg-dom.jar \
batik/lib/batik-util.jar     \
batik/lib/js.jar \
batik/lib/batik-css.jar      \
batik/lib/batik-ext.jar       \
batik/lib/batik-parser.jar   \
batik/lib/batik-svggen.jar  \
batik/lib/batik-xml.jar


.PHONY: batik_link callflow all

all: batik_link callflow

batik_link:
	\rm -f batik
	ln -s $(BATIK_LOCATION) ./batik

callflow:	$(FILES)
	echo "#!/bin/bash" > callflow
	echo mkdir -p .callflow >> callflow
	echo '(cd .callflow; uudecode | tar xf -) <<"finished"' >> callflow
	tar cf - $(FILES) | uuencode /dev/stdout >> callflow
	echo finished >> callflow
	echo '.callflow/callflow.sh $$*' >> callflow
	echo "\\rm -rf .callflow" >> callflow
	chmod a+x callflow

