#!/bin/bash
#
# This file is under source code control.  Do not edit it directly,
# check a copy out using the appropriate SCM. See the `Source' line
# to find the archive.
#
# Shell script to parse purpose files and produce a useful summary.
#
# $Source: /home/scs/RCS/osversions,v $
#
# $Id: osversions,v 1.3 2015/08/04 17:05:02 scs Exp scs $
#
# Revision 1.5 2015/9/29 12:01:59
# run like ./osvsersions html
#
# $Log: osversions,v $
# Revision 1.4  2015/08/04 17:05:02  scs
# More steps towards HTML output.
#
# Revision 1.3  2015/09/28 14:13:01  rndwyer
# Insert html framework to automate html page generation
#
# Revision 1.2  2015/08/04 16:47:25  scs
# Handle new AIX release files correctly, more steps towards HTML output.
#
# Revision 1.1  2015/06/23 17:30:41  scs
# Initial revision
#

# Boilerplate definitions for all scripts.

set -u		    # Undefined variables are latent bugs
TOOL=${0//*\//}     # Get the simple name of this script
TOOL_ARGS="$@"      # Save args in case other things call 'set'

# Turn on debugging if set. If not set or set to anything other
# than "echo", set it to ":".
[[ "echo" != "${DBG:=${DBG_DEFAULT:-:}}" ]] && DBG=":"

# We're gradually adding html output to this so it can be
# run nightly and used as a web page.



#: ${HTML_OUT:=false}

if [[ $# -eq 0 ]] ; then 
	: ${HTML_OUT:=false} ;
else
	if  [[ "html" = "$1" ]] ; then
		HTML_OUT=true; 
	else	echo "Please invoke with "html" as the first positional parameter, or none at all."; exit 1
	fi
fi

#[[ "true" != "$HTML_OUT" ]] && HTML_OUT="false"


# Verify the data areas we need actually exist

if ! cd /share/sysadmin/machine ; then
    echo >&2 "${TOOL}: Cannot access the machine directory."
    exit 1
fi

# Create some early vars.

# Formats for printing simple text

DFMT='%10d  %s\n'
TFMT="      ----  ----------\n$DFMT"
#LFMT="%10.10s  %s\n$DFMT"
LFMT="HTML  ----  ----------\n$DFMT"

# Format for printing HTML output

DHTML='<li>%10d  --  %s</li>\n'
LHTML="%10.10s  %s\n"

HCOUNT_HTML="<h3>%s:%d</h3>\n"
HVERSION_HTML="<h3>%s:</h3>\n"
HDATA_HTML="<p>%s</p>\n"
# Some helper functions

show_releases() {
    local TAG FILES COUNT
    TAG="$1"
    FILES="$2"
    COUNT="$3"
if	[[ "false" == "$HTML_OUT" ]] ; then
	echo " $TAG releases:" ;
else	
	echo " <h3> $TAG releases: </h3>" ;
fi
    cat $(cat $FILES) | grep "^$TAG" | sort | uniq -c > "$TEMP"
add_ul_tag
    if [[ -s "$TEMP" ]] ; then
	cat "$TEMP" | while read N S ; do
	
	    if [[ "false" == "$HTML_OUT" ]] ; then
		printf "$DFMT" $N "$S"
	    else
		printf "$DHTML" $N "$S"
	    fi
	done
del_ul_tag
	if [[ "false" == "$HTML_OUT" ]] ; then
	    #printf "$LFMT" "----" "----------" $COUNT "Total"
	    printf "$TFMT" $COUNT "Total"
	else
   # printf  "$LHTML" "----" "----------"  $COUNT "Total" 
	    echo -en "<h4>---- -------- $COUNT Total</h4>"
	fi
    else
	echo "  No $TAG kernel data found." >&2
    fi
}

show_kernels() {
    local TAG FILES
    TAG="$1"
    FILES="$2"
if [[ "false" == "$HTML_OUT" ]] ; then
	echo "  $TAG kernel versions:" ;
else	
	echo "  <h3> $TAG kernel versions: </h3>" ;
fi
    grep -i ^linux $(cat $FILES) | awk '{print $3}' | sort | uniq -c > "$TEMP"
add_ul_tag
    if [[ -s "$TEMP" ]] ; then
	cat "$TEMP" | while read N S ; do
	    if [[ "false" == "$HTML_OUT" ]] ; then
		printf "$DFMT" $N "$S"
	    else
		printf "$DHTML" $N "$S"
	    fi
	done
del_ul_tag

#	if [[ "false" == "$HTML_OUT" ]] ; then
	    #printf "$LFMT" "----" "----------" $(addcolumn < "$TEMP") "Total"
#	    printf "$TFMT" $(addcolumn < "$TEMP") "Total"
#	else
#	    printf "$LHTML" "----" "----------" $(addcolumn < "$TEMP") "Total"
#	fi
#    else
#	echo "  No kernel data found." >&2
    fi
}
#below are functions to insert html markup
add_ul_tag() {
if
	[[ "false" == "$HTML_OUT" ]] ;then
	:
else
	echo -en "<ul> \n" ;
fi
}
del_ul_tag() {
if
	[[ "false" == "$HTML_OUT" ]] ; then
	:
else
	echo -en "</ul> \n";
fi
}
add_vbox_div() {
if
	[[ "false" == "$HTML_OUT" ]] ; then
	:
else
	echo -en "<div class="vbox"> ";
fi
}

del_vbox_div() {
if
	[[ "false" == "$HTML_OUT" ]] ; then
		:
else
	echo "</div>"
fi
}
#set -xv

TEMP=$(mktemp /tmp/${TOOL}.tmp.XXXXXX)
TEMPFILES="$TEMP"
#Intial HTML formatting
if [[ "false" == "$HTML_OUT" ]] ; then
	:
else
	echo -en "<html> \n <head> \n
<style>
ul { color:white; }
h1,h3 { color:white; }
h4 { color:white; font-size:14px; }
kal{
color:white; 
font-family:Lucida Console, Monaco, monospace; 
white-space: pre;
}
body { padding:50px 50px 50px 50px;
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#35537a), color-stop(120%,#1d2d44)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #35537a 0%,#1d2d44 120%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #35537a 0%,#1d2d44 120%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #35537a 0%,#1d2d44 120%); /* IE10+ */
	background: linear-gradient(top, #35537a 0%,#1d2d44 120%); /* W3C */
	background:-moz-linear-gradient(center top , #35537a 0%, #1d2d44 100%) repeat scroll 0 0 rgba(0, 0, 0, 0) ; height:136%; } 
.vbox {
	border-top:1px solid white;
	color:white;
	width:auto; 
	height:auto;
	float:left;
	padding:22px;
}
</style>
  <title>OS Versions</title>\n<body>\n\n<div style=\"width:520px; position:relative;\" " ;
	echo -en " <!-- The following web page has been generated based on the assorted files inside of /share/sysadmin/machine  on `date` --> \n \n \n"
fi

OS_COUNT=$(ls *.OS 2>/dev/null|wc -l)
if [[ "false" == "$HTML_OUT" ]] ; then
    echo "$OS_COUNT total OS entries"
else
    printf "<h1>$OS_COUNT total OS entries</h1>" 
fi

#add_container_for_AIX
add_vbox_div

# Process all AIX hosts, then break them down by kernel

AIX_TMP=$(mktemp /tmp/${TOOL}.OS.AIX.XXXXX)
TEMPFILES="$TEMPFILES $AIX_TMP"
grep -il ^AIX *.OS 2>/dev/null > "$AIX_TMP"
AIXOSFILES=$(cat "$AIX_TMP")
AIX_COUNT=$(wc -l < "$AIX_TMP")

if [[ "false" == "$HTML_OUT" ]] ; then
    echo "  AIX hosts $AIX_COUNT"
    echo "  AIX kernel versions"
else
    printf "$HCOUNT_HTML    " "AIX hosts " "$AIX_COUNT"
    printf "$HVERSION_HTML" "AIX kernel versions"
fi

#add <ul> element for html output
add_ul_tag

cat $AIXOSFILES | grep -i '^aix .* ' | while read OS H MIN MAJ ID DUMMY ; do
    echo "$MAJ.$MIN"

done | sort | uniq -c | while read N V ; do
    if [[ "false" == "$HTML_OUT" ]] ; then
	printf "$DFMT" $N "$V"
    else
	printf "$DHTML"  $N "$V";	
    fi
done
#echo </ul> on HTML output
del_ul_tag
#close_htmlcontainer_for_AIX
del_vbox_div
#add_htmlcontainer_for_all_versions
add_vbox_div


grep -i ^aix $AIXOSFILES | awk '{print $3}' | sort |uniq -c > "$TEMP"
echo

# Process all Linux hosts, breaking down by recognized flavors.

LINUX_TMP=$(mktemp /tmp/${TOOL}.OS.Linux.XXXXXX)
TEMPFILES="$TEMPFILES $LINUX_TMP"
grep -il ^linux *.OS 2>/dev/null > "$LINUX_TMP"
LINUXOSFILES=$(cat $LINUX_TMP)
LINUX_COUNT=$(wc -l < "$LINUX_TMP")

# List the overall linux types found

if [[ "false" == "$HTML_OUT" ]] ; then
    echo "  Linux hosts: $LINUX_COUNT"
else
    printf "$HCOUNT_HTML" "Linux hosts: $LINUX_COUNT"
fi

RH_TMP=$(mktemp /tmp/${TOOL}.OS.RH.XXXXXX)
TEMPFILES="$TEMPFILES $RH_TMP"
add_ul_tag
grep -il "^Red Hat" $LINUXOSFILES > "$RH_TMP"
RH_COUNT=$(wc -l < "$RH_TMP")
if [[ "false" == "$HTML_OUT" ]] ; then
    printf "$DFMT" $RH_COUNT "Red Hat"
else
    printf "$DHTML" $RH_COUNT "Red Hat"
fi
UMCE_TMP=$(mktemp /tmp/${TOOL}.OS.UMCE.XXXXXX)
TEMPFILES="$TEMPFILES $UMCE_TMP"
grep -il "^UMCE" $LINUXOSFILES > "$UMCE_TMP"
UMCE_COUNT=$(wc -l < "$UMCE_TMP")
if [[ "false" == "$HTML_OUT" ]] ; then
    printf "$DFMT" $UMCE_COUNT "UMCE"
else
    printf "$DHTML" $UMCE_COUNT "UMCE"
fi

GEN2_TMP=$(mktemp /tmp/${TOOL}.OS.gentoo.XXXXXX)
TEMPFILES="$TEMPFILES $GEN2_TMP"
grep -il "^Gentoo" $LINUXOSFILES > "$GEN2_TMP"
GEN2_COUNT=$(wc -l < "$GEN2_TMP")
if [[ "false" == "$HTML_OUT" ]] ; then
    printf "$DFMT" $GEN2_COUNT "Gentoo"
else
    printf "$DHTML" $GEN2_COUNT "Gentoo"
fi

OTHER_COUNT=$(($LINUX_COUNT - $(($RH_COUNT + $UMCE_COUNT + $GEN2_COUNT))))
#printf "$DFMT" $OTHER_COUNT "Unrecognized linux"
if [[ "false" == "$HTML_OUT" ]] ; then
	printf "$DFMT" $OTHER_COUNT "Unrecognized linux"
else	
	printf "$DHTML" $OTHER_COUNT "Unrecognized linux"
fi
if [[ 0 != $OTHER_COUNT ]] ; then
    OTHER_TMP=$(mktemp /tmp/${TOOL}.OS.other.XXXXXX)
    cat $RH_TMP $UMCE_TMP $GEN2_TMP | sort | uniq > "$TEMP"
    comm -23 $LINUX_TMP $TEMP > "$OTHER_TMP"
    if [[ "false" == "$HTML_OUT" ]] ; then
	echo "   See files:" $(cat $OTHER_TMP)
    else
	: # Do nothing for now
    fi
fi
del_ul_tag

#close_htmlcontainer_for_all_versions
del_vbox_div

#add_htmlcontainer_for_rhel_versions
add_vbox_div

# Show the RH linux releases and kernels

echo ""
show_releases "Red Hat" "$RH_TMP" "$RH_COUNT"
show_kernels "Red Hat" "$RH_TMP"

#close_htmlcontainer
del_vbox_div

#add_htmlcontainer_for_UMCE_versions
add_vbox_div

# For UMCE linux we don't bother with the releases or the kernels
# because they're not really meaningful.
#add <ul> element for html output
[[ "false" == "$HTML_OUT" ]] && echo
if [[ 0 == $UMCE_COUNT ]] ; then
    if [[ "false" == "$HTML_OUT" ]] ; then
	echo "  UMCE releases and kernels: none"
    else
	printf "$DHTML" "UMCE releases and kernels: none"
    fi
else
    if [[ "false" == "$HTML_OUT" ]] ; then
	echo "  UMCE has no concept of releases."
    else
#	printf "$DHTML" "UMCE has no concept of releases."
	:
    fi
    show_kernels "UMCE" "$UMCE_TMP"
fi
if [[ "false" == "$HTML_OUT" ]] ; then
	printf "$UMCE_COUNT"  "Total"
else
	echo "<h4>---- ---------- $UMCE_COUNT total</h4>"

#close_UMCE_hmtlcontainer
del_vbox_div

#add_htmlcontainer_for_gentoo
add_vbox_div

# Gentoo is more meaningful
fi

[[ "false" == "$HTML_OUT" ]] && echo
if [[ 0 == $GEN2_COUNT ]] ; then
    if [[ "false" == "$HTML_OUT" ]] ; then
	echo "  Gentoo releases and kernels: none"
    else
	printf "$DHTML" "Gentoo releases and kernels: none"
    fi
else
    show_releases "Gentoo" "$GEN2_TMP" "$GEN2_COUNT"
    show_kernels "Gentoo" "$GEN2_TMP"
fi

#close_gentoo_htmlcontainer
del_vbox_div

#add_htmlcontainer_for_other_releases
add_vbox_div

# If there are ones we can't identify, print what we do have

[[ "false" == "$HTML_OUT" ]] && echo
if [[ 0 == $OTHER_COUNT ]] ; then
    if [[ "false" == "$HTML_OUT" ]] ; then
	echo "  Other releases and kernels: none"
    else
	printf  "<h4>Other releases and kernels: none</h4>"
    fi
else
    if [[ "false" == "$HTML_OUT" ]] ; then
	echo "  Other releases:"
    else
	printf "$DHTML" "Other releases:"
    fi
    cat $(cat $OTHER_TMP) | egrep -vi '^(linux|Red Hat|UMCE|Gentoo)' | sort | uniq -c > "$TEMP"
    if [[ -s "$TEMP" ]] ; then
	cat "$TEMP" | while read N S ; do
	    if [[ "false" == "$HTML_OUT" ]] ; then
		printf "$DFMT" $N "$S"
	    else
		printf "$DHTML" $N "$S"
	    fi
	done
	if [[ "false" == "$HTML_OUT" ]] ; then
	    $printf "$LFMT" "----" "----------" $COUNT "Total"
	    printf "$TFMT" $COUNT "Total"
	else
	    printf "$LHTML" "----" "----------" $COUNT "Total"
	fi
    else
	if [[ "false" == "$HTML_OUT" ]] ; then
	    echo "  No release data found."
	else
	    printf "$DHTML" "No release data found."
	fi
    fi
    show_kernels "Other" "$OTHER_TMP"
fi

MISSINGOS=$(($OS_COUNT - $(($AIX_COUNT + $LINUX_COUNT))))
if [[ 0 == $MISSINGOS ]] ; then
    if [[ "false" == "$HTML_OUT" ]] ; then
	echo ""
	echo "All OS files contained recognizable OS types."
    else
	printf "All OS files contained recognizable OS types."
    fi
else
    if [[ "false" == "$HTML_OUT" ]] ; then
	echo "WARNING: $MISSINGOS OS files contained unrecognizable OS types."
    else
	: # Not clear what we need to do here
    fi
fi

del_vbox_div

rm -f "$TEMPFILES"

if [[ "false" == "$HTML_OUT" ]] ; then
	:
else
	echo -en " </body> \n </html>"
fi
