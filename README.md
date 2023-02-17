# drbdwatch.sh
DRBD resource watchdog script to bounce resource on secondary node if its too far out of sync (oos) and stalled.

Note: Does not support version 9.  Uses /proc/drbd which is no longer used in DRBD version 9/

Usage: ./drbdwatch.sh &lt;resource name:/proc/drbd number&gt;
  
Suggest running this in cron every minute to ensure drbd does not remain out of sync very long<br>
  <i>Add more lines for each resource you want to monitor</i><br>
  Example: <code>*/1 * * * * bash -l -c '/usr/local/bin/drbdwatch.sh r0:1' > /dev/null 2>&1</code>
  
Variables near the top of script can be tuned.  Here are the defaults:<br>
OOS_MAX=256000 #256KB<br>
SYNC_TIMEOUT=1800 #30 Minutes<br>
  
Configuration:<br>
  &nbsp;&nbsp;&nbsp;&nbsp;Edit LOGFILE and LOCKFILE variables if desired<br>
  &nbsp;&nbsp;&nbsp;&nbsp;**Note, LOCKFILE must include the resource variable to ensure uniqueness if running multiple drbdwatch.sh instances**<br>
  &nbsp;&nbsp;&nbsp;&nbsp;Defaults:<br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LOGFILE="/var/log/drbdwatch.log"<br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LOCKFILE="/tmp/.DRDBSYNC_$RESOURCE"<br>
