# drbdwatch.sh
DRBD resource watchdog script to bounce resource on secondary node if its too far out of sync (oos) and stalled.

Usage: ./drbdwatch.sh <resource name>
  
Suggest running this in cron every minute to ensure drbd does not remain out of sync very long
  Add more lines for each resource you want to monitor
  Example: */1 * * * * bash -l -c '/usr/local/bin/drbdwatch.sh r0' > /dev/null 2>&1
  
Configuration:
  Edit LOGFILE and LOCKFILE variables if desired 
  **Note, LOCKFILE must include the resource variable to ensure uniqueness if running multiple drbdwatch.sh instances**
  Defaults:
    LOGFILE="/var/log/drbdwatch.log"
    LOCKFILE="/tmp/.DRDBSYNC_$RESOURCE"
