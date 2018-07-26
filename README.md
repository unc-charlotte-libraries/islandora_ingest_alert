# islandora_ingest_alert
E-mail Alerts for Islandora Ingest Progress


#### Example:
NOW RUNNING: Islandora Batch Set: 650

██████████████░░░░░░ 72% complete

Total Objects: 1437

mss:55620 - mss:57056

#### How does it work?

1. First, the script detects if RSYNC is running (indication of in-bound files), alerts accordingly
2. Second, the script detects if DRUSH is running, and enters detailed alert routine (requires: islandora_batch_ingest --ingest_set=$batch_set_id)
3. If neither RSYNC or DRUSH is running, system sends out "Hungry, Feed Me" e-mails


#### Cron
Run using cron, every hour


#### Configuration:

$upload_directory
RSYNC upload directory to watch (just the directory name, not full path)

/var/log/islandora/fedora/fedora.log (path to your live fedora.log)

/var/log/islandora/tomcat/catalina.out (path to your live catalina.out)

Define destination and sender e-mail addresses

#### One more thing:

The script is watching fedora.log for Islandora's derivative production phase:

grep -i "getDatastream(" 2>&1
