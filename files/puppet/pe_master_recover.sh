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

# Set Initial/Default Variables
TIMESTAMP=`date +"%m%d%Y-%H%M%S"`
HOSTNAME=`hostname -s`
USERNAME='root'
SSH_KEY='/root/.ssh/id_rsa'
PRIMARY_SCRIPT_DIR='/opt/puppetlabs/server/bin'



#############
## Functions
#############
# Print Script Usage
F_Usage () {
  echo
  echo "Usage: pe_master_recover.sh"
  echo
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
while getopts :f:m:u:k:s:h FLAG; do
  case $FLAG in
    f)  # Set the Restore File Location
        BACKUP_FILE=$OPTARG
        ;;
    m)  # Set the Primary MoM IP Address
        PRIMARY_IP=$OPTARG
        ;;
    u)  # Set the user to user for SSH to the Primary MoM
        USERNAME=$OPTARG
        ;;
    k)  # Set the location of the user's SSH Key
        SSH_KEY=$OPTARG
        ;;
    s)  # Set the Location of the restore script on the Primary MoM
        PRIMARY_SCRIPT_DIR=$OPTARG
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

# Ensure we passed a backup file
if [[ -z "$BACKUP_FILE" ]]; then
  echo
  echo "ERROR: No Backup File Specified"
  F_Usage
fi

# Ensure we passed a backup file
if [[ -z "$PRIMARY_IP" ]]; then
  echo
  echo "ERROR: No Primary Master IP Specified"
  F_Usage
fi

# Cleanup temp files
trap F_Exit EXIT



####################
## Perform Recovery
####################

# Test Connection to Primary Master
ssh -o ConnectTimeout=2 -o ConnectionAttempts=2 -o StrictHostKeyChecking=no \
  -i $SSH_KEY $USERNAME@$PRIMARY_IP "echo >/dev/null" >/dev/null
if [[ $? -ne 0 ]]; then
  echo
  echo "ERROR: Failed to SSH to $PRIMARY_IP"
  F_Usage
fi

# Copy Restore file
scp -i $SSH_KEY -o StrictHostKeyChecking=no -i $SSH_KEY \
  $BACKUP_FILE $USERNAME@$PRIMARY_IP:/tmp
if [[ $? -ne 0 ]]; then
  echo
  echo "ERROR: Failed to SCP '$BACKUP_FILE' to $USERNAME@$PRIMARY_IP:/tmp"
  F_Usage
fi

# Execute the Restores
ssh -o StrictHostKeyChecking=no -i $SSH_KEY $USERNAME@$PRIMARY_IP \
  "$PRIMARY_SCRIPT_DIR/pe_master_restore.sh -f /tmp/$BACKUP_FILE; echo $? >/tmp/pe_master_recovery.exit"

# Check the Status
_rc=`ssh -o StrictHostKeyChecking=no -i $SSH_KEY $USERNAME@$PRIMARY_IP 'cat /tmp/pe_master_recovery.exit; rm -f /tmp/pe_master_recovery.exit >/dev/null 2>&1'`
if [[ $_rc -ne 0]]; then
  echo
  echo "ERROR: PE Master recovery returned exit code of $_rc"
  F_Usage
fi

echo "PE Master recovery Complete"
exit 0
