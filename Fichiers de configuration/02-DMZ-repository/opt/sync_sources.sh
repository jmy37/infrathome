#!/bin/sh

# This script is part of Infr@Home Information System
# It is under GPL-V3 license
#
# Versionning
# YYYYMMDD_hhmm | Author                | Changelog
# 20201018_1436 | jmy37                 | Script creation
# 20201210_1431 | jmy37                 | Add rsync and wget repositories
#

# Variables
WEB_PATH=/var/www/html
LOG_PATH=/var/log
ERROR_LOG=$LOG_PATH/sync_error.log
DEBUG_LOG=$LOG_PATH/sync_debug.log
REPOLIST_FILES=/opt
CENTOS_REPOLIST=$REPOLIST_FILES/centos
RSYNC_REPOLIST=$REPOLIST_FILES/rsync
WGET_REPOLIST=$REPOLIST_FILES/wget

# System variables
TOUCH_BIN=/usr/bin/touch
REPOSYNC_BIN=/usr/bin/reposync
RSYNC_BIN=/usr/bin/rsync
WGET_BIN=/usr/bin/wget
CURL_BIN=/usr/bin/curl

# Create log files
$TOUCH_BIN $ERROR_LOG
$TOUCH_BIN $DEBUG_LOG

# Starting synchronization
NOW=$(date +"%Y %m %d  %T")
echo -e "["$NOW"] Start syncing..." >> $DEBUG_LOG

# CentOS sync
while IFS=, read -r CENTOS_RELEASE REPOID
do
  NOW=$(date +"%Y %m %d  %T")
  echo -e "["$NOW"] Starting to sync ["$REPOID"]..." >> $DEBUG_LOG
  if $REPOSYNC_BIN --download-metadata --delete --download-path=$WEB_PATH/centos/$CENTOS_RELEASE/ --repoid=$REPOID >> $DEBUG_LOG ; then
    NOW=$(date +"%Y %m %d  %T")
    echo -e "["$NOW"] Repo ["$REPOID"] successfully synced" >> $DEBUG_LOG
  else
    echo -e "["$NOW"] Error syncing ["$REPOID"]" >> $ERROR_LOG
    echo -e "["$NOW"] Error syncing ["$REPOID"]" >> $DEBUG_LOG
  fi
done < $CENTOS_REPOLIST

# Rsync repositories
while IFS=, read -r REPOID RSYNC_URL
do
  NOW=$(date +"%Y %m %d  %T")
  echo -e "["$NOW"] Starting to sync ["$REPOID"]..." >> $DEBUG_LOG
  if $RSYNC_BIN --archive --hard-links --numeric-ids --stats rsync://$RSYNC_URL $WEB_PATH/$REPOID/ >> $DEBUG_LOG ; then
    NOW=$(date +"%Y %m %d  %T")
    echo -e "["$NOW"] Repo ["$REPOID"] successfully synced" >> $DEBUG_LOG
  else
    echo -e "["$NOW"] Error syncing ["$REPOID"]" >> $ERROR_LOG
    echo -e "["$NOW"] Error syncing ["$REPOID"]" >> $DEBUG_LOG
  fi
done < $RSYNC_REPOLIST

# Wget repositories
while IFS=, read -r REPOID WGET_CUTDIRS WGET_DOMAIN WGET_URL
do
  NOW=$(date +"%Y %m %d  %T")
  echo -e "["$NOW"] Starting to sync ["$REPOID"]..." >> $DEBUG_LOG
  if $WGET_BIN --quiet --reject=md5,txt,html,tmp --recursive --no-host-directories --cut-dirs=$WGET_CUTDIRS --convert-links --no-parent --domains=$WGET_DOMAIN --directory-prefix=$WEB_PATH/$REPOID/ $WGET_URL >> $DEBUG_LOG ; then
    NOW=$(date +"%Y %m %d  %T")
    echo -e "["$NOW"] Repo ["$REPOID"] successfully synced" >> $DEBUG_LOG
  else
    echo -e "["$NOW"] Error syncing ["$REPOID"]" >> $ERROR_LOG
    echo -e "["$NOW"] Error syncing ["$REPOID"]" >> $DEBUG_LOG
  fi
done < $WGET_REPOLIST

# End of script
echo -e "["$NOW"] Syncing is over. Thanks to check log above for errors." >> $DEBUG_LOG

exit

