#!/bin/bash
date_iso8601=$(/bin/date --iso-8601=seconds)
rsync_detection=$(lsof | grep rsync | grep upload_directory | grep -e "[[:digit:]]\+[w]\{1\}" | tr -s " " | cut -d " " -f 9)
rsync_detection_count=$(echo -e "$rsync_detection" | tr -d " " | wc -c)

#debug
#echo $rsync_detection
#echo $rsync_detection_count

if (( $rsync_detection_count > '1'))
then
  /bin/echo -e "NOW UPLOADING:\n$rsync_detection" | /usr/bin/mail -s "RSYNC In Progress: $date_iso8601" archivistalert@domain.edu -aFrom:email@address.edu
  exit
else
  drush_detection=$(ps aux 2>/dev/null |grep drush 2>/dev/null |wc -l | tr -s " ")
  if (( $drush_detection > 1 ))
  then
    islandora_batch_set=$(ps aux 2>/dev/null |grep drush |grep ingest_set |  tr -s " " | cut -d " " -f 22 | cut -d "=" -f 2)
    
    if [ -z "$islandora_batch_set" ]
    then
      exit
    fi
    
    set_total_objects=$(/usr/local/bin/drush -c /usr/local/drush/drushrc.php sql-query "SELECT COUNT(*) FROM islandora_batch_queue WHERE sid = '$islandora_batch_set'")
    set_first_pid=$(/usr/local/bin/drush -c /usr/local/drush/drushrc.php sql-query "SELECT id FROM islandora_batch_queue WHERE sid = '$islandora_batch_set' ORDER BY id ASC LIMIT 1")
    set_first_pid_serial=$(echo "$set_first_pid" | cut -d ":" -f 2)
    set_last_pid=$(/usr/local/bin/drush -c /usr/local/drush/drushrc.php sql-query "SELECT id FROM islandora_batch_queue WHERE sid = '$islandora_batch_set' ORDER BY id DESC LIMIT 1")
    set_last_pid_serial=$(echo "$set_last_pid" | cut -d ":" -f 2)
    fedora_log=$(tail -n 50 /var/log/islandora/fedora/fedora.log | grep -i getDatastream | cut -d " " -f 8,9,10 | rev | cut -c 2- | rev)
    solr_log=$(tail -n 300 /var/log/islandora/tomcat/catalina.out | grep add | cut -d " " -f 6 | cut -d "[" -f 2)
    
    progress_needle=$(tail -n 10 /var/log/islandora/fedora/fedora.log | grep -i "getDatastream(" 2>&1 | head -n 1 | cut -d " " -f 8 | rev | cut -c 2- | rev)
    if [ -z "$progress_needle" ]
    then
      exit
    elif [ "$progress_needle" -ge "$set_first_pid_serial" -a "$progress_needle" -le "$set_last_pid_serial" ]
    then
      exit
    fi
    
    progress_islandora_set=$(/usr/local/bin/drush -c /usr/local/drush/drushrc.php sql-query "SET @row_number = 0; CREATE TEMPORARY TABLE IF NOT EXISTS islandora_batch_status_indicator AS (SELECT (@row_number:=@row_number + 1) AS row, id, sid FROM islandora_batch_queue WHERE sid = $islandora_batch_set); SELECT row from islandora_batch_status_indicator WHERE id = '$progress_needle'")
    if [ -z "$progress_islandora_set" ]
    then
      exit
    fi
    
    #debug
    #echo "progress_needle: $progress_needle"
    #echo "progress_islandora_set: $progress_islandora_set"
    
    #progress formula
    #($progress_number * 100) / $total_number = $percentage_progress

    ingest_progress=$(echo "$(( ($progress_islandora_set * 100) / $set_total_objects ))")
    #echo "ingest_progress: $ingest_progress"
    if (( $ingest_progress > 0 && $ingest_progress < 5 )); then
      progress_indicator='░░░░░░░░░░░░░░░░░░░░'
      elif (( $ingest_progress >= 5 && $ingest_progress < 10 )); then
      progress_indicator='█░░░░░░░░░░░░░░░░░░░'
      elif (( $ingest_progress >= 10 && $ingest_progress < 15 )); then
      progress_indicator='██░░░░░░░░░░░░░░░░░░'
      elif (( $ingest_progress >= 15 && $ingest_progress < 20 )); then
      progress_indicator='███░░░░░░░░░░░░░░░░░'
      elif (( $ingest_progress >= 20 && $ingest_progress < 25 )); then
      progress_indicator='████░░░░░░░░░░░░░░░░'
      elif (( $ingest_progress >= 25 && $ingest_progress < 30 )); then
      progress_indicator='█████░░░░░░░░░░░░░░░'
      elif (( $ingest_progress >= 30 && $ingest_progress < 35 )); then
      progress_indicator='██████░░░░░░░░░░░░░░'
      elif (( $ingest_progress >= 35 && $ingest_progress < 40 )); then
      progress_indicator='███████░░░░░░░░░░░░░'
      elif (( $ingest_progress >= 40 && $ingest_progress < 45 )); then
      progress_indicator='████████░░░░░░░░░░░░'
      elif (( $ingest_progress >= 45 && $ingest_progress < 50 )); then
      progress_indicator='█████████░░░░░░░░░░░'
      elif (( $ingest_progress >= 50 && $ingest_progress < 55 )); then
      progress_indicator='██████████░░░░░░░░░░'
      elif (( $ingest_progress >= 55 && $ingest_progress < 60 )); then
      progress_indicator='███████████░░░░░░░░░'
      elif (( $ingest_progress >= 60 && $ingest_progress < 65 )); then
      progress_indicator='████████████░░░░░░░░'
      elif (( $ingest_progress >= 65 && $ingest_progress < 70 )); then
      progress_indicator='█████████████░░░░░░░'
      elif (( $ingest_progress >= 70 && $ingest_progress < 75 )); then
      progress_indicator='██████████████░░░░░░'
      elif (( $ingest_progress >= 75 && $ingest_progress < 80 )); then
      progress_indicator='███████████████░░░░░'
      elif (( $ingest_progress >= 80 && $ingest_progress < 85 )); then
      progress_indicator='████████████████░░░░'
      elif (( $ingest_progress >= 85 && $ingest_progress < 90 )); then
      progress_indicator='█████████████████░░░'
      elif (( $ingest_progress >= 90 && $ingest_progress < 95 )); then
      progress_indicator='██████████████████░░'
      elif (( $ingest_progress >= 95 && $ingest_progress < 100 )); then
      progress_indicator='███████████████████░'
      elif (( $ingest_progress == 100 )); then
      progress_indicator='███████████████████♥'
    else
      progress_indicator='░░░░░░░░░░░░░░░░░░░░'
    fi
    
    /bin/echo -e "NOW RUNNING: Islandora Batch Set: $islandora_batch_set\n\n$progress_indicator $ingest_progress% complete\n\nTotal Objects: $set_total_objects\n\n$set_first_pid - $set_last_pid" | /usr/bin/mail -s "Set $islandora_batch_set INGESTING: $ingest_progress% complete" archivistalert@domain.edu -aFrom:email@address.edu
  else
    /bin/echo -e "FEED ME OBJECTS SEYMORE" | /usr/bin/mail -s "Hungry, Feed Me" archivistalert@domain.edu -aFrom:email@address.edu
  fi
fi
