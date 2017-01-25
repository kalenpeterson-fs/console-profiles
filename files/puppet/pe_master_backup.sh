#!/bin/bash
#  Perform a backup of a PE Master
#   These backups can be restored by the pe_master_restore.sh script
#   Must be run on the PE Master (or Master of Masters)
#
# Prerequisites
#  You must have a functinall master installed and running
#
#  Process being followed
#   - Archive all config files, certificates, and keys
#   - Backup the PuppetDB and add to archive
#
#  Tested with the following PE versions
#   - 2016.2.1
#   - 2016.4.2
#
#  Usage: See F_Usage
#
#  Written by: Kalen Peterson <kpeterson@forsythe.com>
#  Created on: 11/23/2016

# Set Initial Variables
TIMESTAMP=`date +"%m%d%Y-%H%M%S"`
HOSTNAME=`hostname -s`
ARCHIVE_FILE="pe_backup.$HOSTNAME.$TIMESTAMP.tar.gz"
SQL_FILE="pe_sql_backup.sql"



#############
## Functions
#############
# Print Script Usage
F_Usage () {
  echo
  echo "Usage: pe_master_backup.sh -d DIRECTORY"
  echo
  echo "Options:"
  echo "  -d    *Required* Specify a directory to store backups"
  echo "  -h    Print this usage info"
  echo
  echo "This script will backup a PE Master to an archive from which it can be restored."
  echo
  echo "It must be run from the PE Master or Master of Masters."
  exit 2
}

# Perform cleanup on script exit
F_Exit () {
  rm -f "$BACKUP_DIR/$SQL_FILE"
}



#############
## Arguments
#############
# Manage Options
while getopts :d:n:h FLAG; do
  case $FLAG in
    d)  # Set the Restore File Location
        BACKUP_DIR=$OPTARG
        ;;
    n)  # Set the Archive File Name
        ARCHIVE_FILE=$OPTARG
        ;;
    h)  # Show Usage
        F_Usage
        ;;
   /?)  # Unknown Option, show usage
        echo "ERROR: Unknown option '$FLAG $OPTARG'"
        F_Usage
        ;;
  esac
done



##############
## Validation
##############
# Validate that we are root
if [[ `id -u` -ne 0 ]]; then
  echo
  echo "ERROR: You must be root!"
  F_Usage
fi

# Ensure we passed a backup directory
if [[ -z "$BACKUP_DIR" ]]; then
  echo
  echo "ERROR: No Backup Directory specified"
  F_Usage
fi

# Ensure the backup directory exists
if [[ ! -d "$BACKUP_DIR" ]]; then
  mkdir -p "$BACKUP_DIR"
fi

# Cleanup temp files
rm -f "$BACKUP_DIR/$SQL_FILE"
trap F_Exit EXIT



##################
## Perform Backup
##################

# Backup the PuppetDB
#  This is a postgres hotbackup
echo
echo "Starting DB Dump"
touch "$BACKUP_DIR/$SQL_FILE" \
  || exit 4
chown pe-postgres: "$BACKUP_DIR/$SQL_FILE" \
  || exit 5
chmod 640 "$BACKUP_DIR/$SQL_FILE" \
  || exit 6
sudo -u pe-postgres \
  /opt/puppetlabs/server/apps/postgresql/bin/pg_dumpall \
  -c -f "$BACKUP_DIR/$SQL_FILE" \
  || exit 7

# Create an archive file with..
#  - Configuration directory & symlink
#  - pe-api home directory
#  - Puppet DB
#  - Certificates
#  - Keys
echo
echo "Starting Archive of files"
tar -czf "$BACKUP_DIR/$ARCHIVE_FILE" -C "$BACKUP_DIR" \
  /etc/puppetlabs \
  /opt/puppetlabs/etc/puppetlabs \
  /opt/app/pe-api \
  /opt/puppetlabs/server/data/console-services/certs \
  /opt/puppetlabs/server/data/postgresql/9.4/data/certs \
  /opt/puppetlabs/server/data/puppetserver/.ssh \
  "$SQL_FILE" \
  || exit 8
chmod 640 "$BACKUP_DIR/$ARCHIVE_FILE" \
  || exit 9

echo
echo "PE Master backup Complete"
exit 0
