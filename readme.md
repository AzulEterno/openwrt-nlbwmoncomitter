# OpenWrt nlbwmoncomitter


## Rationale

By default, with OpenWrt nlbwmon database is kept in temporary (RAM) storage. This simple init script backups the database on router shutdown and restores it on router startup (with optional periodic backups in between). This way, the RRD database persists across (planned) reboots.

## Prerequisites

None that aren't covered with a basic OpenWrt install. The script doesn't really make sense if you're not running nlbwmon, though. :wink:

## Compatibility

Tested with OpenWrt 19.07, 21.02, 22.03, and snapshots as of May 2022. This is a very basic script using very fundamental OpenWrt mechanisms that haven't changed in eons.

## Installation

* upload `/etc/init.d/nlbwmoncomitter` and make it executable (`chmod +x /etc/init.d/nlbwmoncomitter`)

* optional: adjust the variables for backup path and filename at the top of the script if you're unhappy with the defaults

* enable the script: `/etc/init.d/nlbwmoncomitter enable`

* optional: make an entry in crontab to backup in regular intervals (e.g.  
  `0 */6 * * * /etc/init.d/nlbwmoncomitter backup`  
  for a backup every 6 hours)
