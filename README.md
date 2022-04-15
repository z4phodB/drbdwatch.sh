# drbdwatch.sh
DRBD resource watchdog script to bounce resource on secondary node if its too far out of sync (oos) and stalled.

Usage: ./drbdwatch.sh &lt;resource name&gt;
  
Suggest running this in cron every minute to ensure drbd does not remain out of sync very long<br>
  &nbsp;&nbsp;&nbsp;&nbsp;Add more lines for each resource you want to monitor<br>
  &nbsp;&nbsp;&nbsp;&nbsp;Example: */1 * * * * bash -l -c '/usr/local/bin/drbdwatch.sh r0' > /dev/null 2>&1
  
Configuration:<br>
  &nbsp;&nbsp;&nbsp;&nbsp;Edit LOGFILE and LOCKFILE variables if desired<br>
  &nbsp;&nbsp;&nbsp;&nbsp;**Note, LOCKFILE must include the resource variable to ensure uniqueness if running multiple drbdwatch.sh instances**<br>
  &nbsp;&nbsp;&nbsp;&nbsp;Defaults:<br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LOGFILE="/var/log/drbdwatch.log"<br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LOCKFILE="/tmp/.DRDBSYNC_$RESOURCE"<br>
