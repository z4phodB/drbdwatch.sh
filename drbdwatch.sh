#!/bin/bash
RESOURCE=$1

if [ -z $RESOURCE ]; then
  echo "You must supply a resource name, ex: drbdwatch.sh r0"
  exit
fi

OOS=`drbdsetup status -v -s $RESOURCE | grep out-of-sync | awk '{print $3}' | awk -F":" '{print $2}'`
STATE=`drbdadm status | grep $RESOURCE | awk -F: '{print $NF}'`
OOS_MAX=256000
SYNC_TIMEOUT=1800

#Edit LOGFILE and LOCKFILE if desired //Note, LOCKFILE must include the resource variable to ensure uniqueness
LOGFILE="/var/log/drbdwatch.log"
LOCKFILE="/tmp/.DRDBSYNC_$RESOURCE"

if [ $STATE != "Secondary" ]; then
  echo "`date` [$OOS] We are not secondary node, exiting." >> $LOGFILE
  exit
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
  elif [ $DIFF -gt $SYNC_TIMEOUT ]; then
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

if [ $OOS -gt $OOS_MAX ]; then

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
