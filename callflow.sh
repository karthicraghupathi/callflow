#!/bin/bash

###  CallFlow diagram generator
###
###  Usage:  callflow.sh capture-file | -t text-input file
###
###  Output: callflow.svg, callflow.jpg, index.html, frames/frame*.html
###
###  Files:  order, filter, ~/.order, ~/.filter
###

if [ -f session ]; then
    sessionFile=session;
elif [ -f ~/.session ]; then
    sessionFile=~/.session;
else
    sessionFile=none;
fi

if [ -n "$1" ]; then
  case "$1" in
    -t|-d)
       inputfile=$2;
       ;;
    -s)
       if [ sessionFile = none ]; then
          echo "You must create either ~/.session or ./session to use -s option";
	  exit 1;
       fi
       inputfile=$2;
       ;;
    -o)
       .callflow/getnodes $2;
       exit 0;
       ;;
     *)
       ;;
  esac
fi


if [ -f filter ]; then
    filterFile=filter;
elif [ -f ~/.filter ]; then
    filterFile=~/.filter;
else
    filterFile=none;
fi

if [ -f order ]; then
    orderFile=order;
elif [ -f ~/.order ]; then
    orderFile=~/.order;
else
    orderFile=none;
fi

if [ -f title ]; then
    titleFile=title;
elif [ -f ~/.title ]; then
    titleFile=~/.title;
else
    titleFile=none;
fi

if [ -n "$inputfile" ]; then
  if [ -e $inputfile ]; then
    cp $inputfile callflow.short
  fi
  if [ -e $inputfile".long" ]; then
    if [ $inputfile".long" != callflow.long ]; then
      cp $inputfile".long" callflow.long
    fi
  fi
elif [ $filterFile != none ]; then
    echo Using the following ethereal display filter:
    cat $filterFile
    tethereal -r $1 -R "`cat $filterFile`" -o 'column.format:"No.","%m","Src","%s","Port","%S","Ignored","%m","Dest","%d","Port","%D","Protocol","%p","Info","%i"' > callflow.short
    tethereal -r $1 -R "`cat $filterFile`" -V > callflow.long
else
    echo 'warning:  filter file not found -- no filters applied'
    tethereal -r $1 -o 'column.format: "No.", "%m", "Src", "%s", "Port", "%S", "Ignored", "%m", "Dest", "%d", "Port", "%D", "Protocol", "%p", "Info", "%i"' > callflow.short
    tethereal -r $1 -V > callflow.long
fi

mkdir -p frames
if [ -n "$inputfile" ]; then
	case "$inputfile" in
		callflow-source.cap)
		;;
		*)
		ln -sf $inputfile callflow-source.cap
		;;
	esac
else
	case "$1" in
		callflow-source.cap)
		;;
		*)
		ln -sf $1 callflow-source.cap
		;;
	esac
fi

if [ -e callflow.long ]; then
  awk -f .callflow/long2html.awk < callflow.long
fi

if [ $1 = "-d" ]; then
    awk -f .callflow/removedups.awk < callflow.short > callflow.short.new
    rm callflow.short
    mv callflow.short.new callflow.short
fi

if [ $1 = "-s" ]; then
    awk -f .callflow/marksession.awk --assign session_token="`cat $sessionFile`" < callflow.short > callflow.short.new
    rm callflow.short
    mv callflow.short.new callflow.short
fi


awk -f .callflow/getnodes.awk < callflow.short > /tmp/callflow.auto-nodelist.$PPID
sort /tmp/callflow.auto-nodelist.$PPID > /tmp/callflow.auto-sortednodes.$PPID
uniq /tmp/callflow.auto-sortednodes.$PPID > /tmp/callflow.auto-uniq.$PPID

if [ $orderFile != none ]; then
    # add forced nodes
    cp /tmp/callflow.auto-uniq.$PPID /tmp/callflow.auto-uniq-forced.$PPID
    grep "!f!" $orderFile | cut -d " " -f 1 >> /tmp/callflow.auto-uniq-forced.$PPID
    cut -d " " -f 1 < $orderFile > /tmp/callflow.order-nodes.$PPID
    
    # prune nodes not appearing in capture file and not forced.
    grep -w -v -f /tmp/callflow.auto-uniq-forced.$PPID /tmp/callflow.order-nodes.$PPID > /tmp/callflow.prune-candidate.$PPID
    awk -f .callflow/makevars.awk < /tmp/callflow.prune-candidate.$PPID > /tmp/callflow.prune-vars.$PPID
    cat /tmp/callflow.prune-vars.$PPID .callflow/prunenodes.awk > /tmp/callflow.prune-awk.$PPID
    awk -f /tmp/callflow.prune-awk.$PPID < callflow.short > /tmp/callflow.auto-not-pruned.$PPID
    grep -w -v -f /tmp/callflow.auto-not-pruned.$PPID /tmp/callflow.prune-candidate.$PPID > /tmp/callflow.auto-prune.$PPID
    grep -w -v -f /tmp/callflow.auto-prune.$PPID /tmp/callflow.order-nodes.$PPID > /tmp/callflow.order-nodes-pruned.$PPID
    
    # add nodes appearing in capture file but not in order file
    cp /tmp/callflow.order-nodes-pruned.$PPID /tmp/callflow.order-nodes-final.$PPID
    grep -w -f /tmp/callflow.auto-uniq-forced.$PPID /tmp/callflow.order-nodes.$PPID >> /tmp/callflow.order-nodes-final.$PPID
    grep -w -f /tmp/callflow.order-nodes-final.$PPID $orderFile > /tmp/callflow.order.$PPID
    grep -w -v -E -f /tmp/callflow.order-nodes.$PPID /tmp/callflow.auto-uniq-forced.$PPID >> /tmp/callflow.order.$PPID
    sed "s/!f!//g" < /tmp/callflow.order.$PPID > /tmp/callflow.order-final.$PPID
    
    echo Using the following order:
    
    cat /tmp/callflow.order-final.$PPID
    awk -f .callflow/makevars.awk < /tmp/callflow.order-final.$PPID > /tmp/callflow.vars.$PPID
else
    echo '$HOME/.order file not found -- using alphabetical'
    awk -f .callflow/makevars.awk < /tmp/callflow.uniq.$PPID > /tmp/callflow.vars.$PPID
fi

if [ $titleFile != none ]; then
	title=`cat $titleFile`;
else
	if [ -n "$inputfile" ]; then
		title=`basename $inputfile`;
	else
		title=`basename $1`;
	fi
fi
echo "title=\"$title\"" >> /tmp/callflow.vars.$PPID

cat /tmp/callflow.vars.$PPID .callflow/callflow.awk > /tmp/callflow.awk.$PPID


awk -f /tmp/callflow.awk.$PPID \
	--assign numLines=`awk -f .callflow/wc.awk < callflow.short`\
                  < callflow.short \
                  > callflow.svg
\rm /tmp/callflow.*.$PPID

#  check to see if java and the batik rasterizer are installed

which java 2>&1 > /dev/null
if [ $? == 1 ]; then
    echo Java not found -- not running rasterizer
else
    java -jar .callflow/batik/batik-rasterizer.jar -q 0.9 -m image/jpg callflow.svg

    echo "<html>" > index.html
    cat imagemap >> index.html
    echo "<p align='center'>" >> index.html
    echo "<img border='0' src='callflow.jpg' usemap='#callflowmap'></img>" >> index.html
    echo "</p>" >> index.html
    echo "<a href='callflow-source.cap'>callflow-source.cap</a>" >> index.html
    echo "</html>" >> index.html
fi

\rm imagemap

exit 0;
