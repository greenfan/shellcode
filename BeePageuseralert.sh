#!/bin/bash
#
# comb through beepage logs, send rndwyer results of sendmail grep
results="$(grep "sendmail" /var/log/daemon)"
[ "$results"  ]  &&  echo "$results" | mail -s "BeePage-Usage-Detected" asdfasdf@yahoo.com
