#!/usr/bin/sh

# Agent side script for AIX Errpt plug-in service monitor
# Usage:
# errpt.sh <offset hours>

PROG="ERRPT.SH"
ERRPT="/usr/bin/errpt"
EXPR="/usr/bin/expr"
DATE="/usr/bin/date"
GNU_DATE=false          # true or false (true for those running the GNU version of date)
                        # The GNU date has not been tested!

hours_ago()
{
# This function gives the date X hours ago
# in a format understood by AIX Errpt command.
# Coordinated Universal Time (TZ=UTC) is used together
# with the time difference between UTC and the local time
# to do this. The difference is calculated each time
# to avoid complications caused by daylight saving
# and the great number of possible local timezones.
# Any timezone could be used instead of UTC since
# we take into account the time difference here.

        OFFSET="$1" # $OFFSET hours ago

        M=`$DATE +"%M"`
        S=`$DATE +"%S"`
        if [ $M -eq 59 -a $S -gt 50 ]
        then
                sleep 10 # Make sure that DT is not calculated when the hour changes!
        fi
        # Local time = Universal Time Coordinated - $DT
        LOCAL=`$DATE +"%H"`
        UTC=`TZ=UTC $DATE +"%H"`
        DT=`$EXPR $UTC - $LOCAL`
        #####################################

        TSHIFT=`$EXPR $DT + $OFFSET`

        TZ=UTC+$TSHIFT $DATE +"%m%d%H%M%y" # print date to stdout
        # which equals to TZ=LOCAL_TIMEZONE+$OFFSET date
        # which equals to TZ=LOCAL_TIMEZONE date $OFFSET hours ago
}

if [ ! $# = 1 ]
then
        echo "usage: errpt.sh <offset hours>"
        exit 1
fi

CURRENT_HOURS=$1

if [ ! -f "$ERRPT" ]
then
        echo "${PROG}: Can't find ERRPT, permission problem?";
        exit 1
fi

if "$GNU_DATE"
then
        current=`$DATE --date "$CURRENT_HOURS hour ago" +"%m%d%H%M%y"`
else
        current=`hours_ago $CURRENT_HOURS`
fi

if [ "$current" = "" ]
then
        echo "${PROG}: Error defining \$current variable!"
        exit 1
fi

${ERRPT} -s "${current}"

exit 0
