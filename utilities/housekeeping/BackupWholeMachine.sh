#!/bin/sh
######################################################################################################
# Author: Peter Winter
# Date :  9/4/2023
# Description: This script will make a complete machine backup which can be used to restore a working
# solution and you can schedule this to run from cron if you want to or you can use this as a way of
# building your machines more quickly in general. If you simply build a particular machine type from
# an archive set that this scipt has produced it should build more quickly for you than building a brand
# new virgin machine
######################################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################################################
#set -x


HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
SERVER_USER_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

machine_type=""

if ( [ "`/usr/bin/hostname | /bin/grep '\-rp-'`" ] )
then
        machine_type="proxy"
elif ( [ "`/usr/bin/hostname | /bin/grep '^ws-'`" ] )
then
        machine_type="webserver"
elif ( [ "`/usr/bin/hostname | /bin/grep '^auth-'`" ] )
then
        machine_type="authenticator"
fi


backup_bucket="`/bin/echo "${WEBSITE_URL}"-whole-machine-backup | /bin/sed 's/\./-/g'`-${machine_type}"

${HOME}/providerscripts/datastore/MountDatastore.sh ${backup_bucket}

${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${backup_bucket}/*

if ( [ ! -d /tmp/dump ] )
then
        /bin/mkdir /tmp/dump
else
        /bin/rm -r /tmp/dump/*
fi

${SUDO} /usr/bin/tar cvpzf - --exclude='backup.tar.gz' --exclude='dev/*' --exclude='proc/*' --exclude='sys/*' --exclude='tmp/*' --exclude='run/*' --exclude='mnt/*' --exclude='media/*' --exclude='lost+found/*' / | /usr/bin/split --bytes=50MB - /tmp/dump/backup.tar.gz.

archives="`/bin/ls /tmp/dump/*backup*`"

for archive in ${archives}
do
        ${HOME}/providerscripts/datastore/PutToDatastore.sh ${archive} ${backup_bucket}
done

/bin/rm -r /tmp/dump
