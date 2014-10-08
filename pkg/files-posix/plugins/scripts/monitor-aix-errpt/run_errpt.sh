#!/bin/sh

UPTIME_DIR=`grep ^inst /etc/init.d/uptime_httpd | cut -d= -f2`
export UPTIME_DIR

perl ./check_aixerrpt.pl
