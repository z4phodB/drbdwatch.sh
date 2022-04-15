#!/bin/bash
RESOURCE=$1
OOS=`cat /proc/drbd | grep ns:.*nr: | awk -F: '{print $NF}'`
STATE=`drbdadm status | grep $RESOURCE | awk -F: '{print $NF}'`

#Edit LOGFILE and LOCKFILE if desired //Note, LOCKFILE must include the resource variable to ensure uniqueness
LOGFILE="/var/log/drbdwatch.log"
LOCKFILE="/tmp/.DRDBSYNC_$RESOURCE"

if [ $STATE != "Secondary" ]; then
  echo "`date` [$OOS] We are not secondary node, exiting." >> $LOGFILE
fi

#If sync lock file exists and no backlog, remove lock and exit
if [ -f $LOCKFILE ]; then
  NOW=`date +'%s'`
  LASTMOD=`stat -c '%Y' $LOCKFILE`
  DIFF=`expr $NOW - $LASTMOD`
  if [ $OOS -eq 0 ]; then
    echo "`date` [$RESOURCE][$OOS] Fully synced, removing lock." >> $LOGFILE
    rm $LOCKFILE
    exit
  elif [ $DIFF -gt 1800 ]; then
    echo "`date` [$RESOURCE][$OOS] Out of Sync, sync already running. Time exceeded 30 minutes, bouncing $RESOURCE" >> $LOGFILE
    /sbin/drbdadm down $RESOURCE
    sleep 3
    /sbin/drbdadm up $RESOURCE
    rm $LOCKFILE
    touch $LOCKFILE
    exit
  else
    echo "`date` [$RESOURCE][$OOS] Out of Sync, sync already running." >> $LOGFILE
    exit
  fi
fi

if [ $OOS -gt 1000000 ]; then

  #If already run and out of sync exit
  if [ -f $LOCKFILE ]; then
    echo "`date` [$RESOURCE][$OOS] Out of Sync, sync already running." >> $LOGFILE
    exit
  fi

  echo "`date` [$RESOURCE][$OOS] Out of Sync, bouncing $RESOURCE." >> $LOGFILE
  #create lock file so we don't overlap
  touch $LOCKFILE
  
  #bounce resource to force sync
  /sbin/drbdadm down $RESOURCE
  sleep 3 
  /sbin/drbdadm up $RESOURCE

  exit

fi