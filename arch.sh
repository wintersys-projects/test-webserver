#!/bin/sh

#Get ourselves orientated so we know where our home is
USER_HOME="`/usr/bin/awk -F: '{ print $1}' /etc/passwd | /bin/grep "X*X"`"
/bin/echo 'export HOME="/home/'${USER_HOME}'"' >> /home/${USER_HOME}/.bashrc
/bin/chmod 644 /home/${USER_HOME}/.bashrc
/bin/chown ${USER_HOME}:root /home/${USER_HOME}/.bashrc
/bin/echo "set mouse=r" > /root/.vimrc

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

#Set the intialial permissions for the build
/usr/bin/find ${HOME} -not -path '*/\.*' -type d -print0 | xargs -0 chmod 0755 # for directories
/usr/bin/find ${HOME} -not -path '*/\.*' -type f -print0 | xargs -0 chmod 0500 # for files
/bin/chown ${SERVER_USER}:root ${HOME}/.ssh
/bin/chmod 750 ${HOME}/.ssh

/bin/echo 'export HOME=`/bin/cat /home/homedir.dat` && /bin/sh ${1} ${2} ${3} ${4} ${5} ${6}' > /usr/bin/run
/bin/chown ${SERVER_USER}:root /usr/bin/run
/bin/chmod 750 /usr/bin/run
/bin/echo 'export HOME=`/bin/cat /home/homedir.dat` && /usr/bin/run ${HOME}/application/configuration/ApplicationConfigurationUpdate.sh' > /usr/bin/config
/bin/chown ${SERVER_USER}:root /usr/bin/run
/bin/chmod 750 /usr/bin/config

#Set up more operational directories
if ( [ ! -d ${HOME}/.ssh ] )
then
    /bin/mkdir ${HOME}/.ssh
fi

if ( [ ! -d ${HOME}/runtime ] )
then
    /bin/mkdir ${HOME}/runtime
    /bin/chown ${SERVER_USER}:${SERVER_USER} ${HOME}/runtime
    /bin/chmod 755 ${HOME}/runtime
fi

#Setup operational directories if needed
if ( [ ! -d ${HOME}/logs/initialbuild ] )
then
    /bin/mkdir -p ${HOME}/logs/initialbuild
fi

if ( [ ! -d ${HOME}/super ] )
then
    /bin/mkdir ${HOME}/super
fi

/bin/mv ${HOME}/utilities/security/Super.sh ${HOME}/super
/bin/chmod 400 ${HOME}/super/Super.sh

out_file="initialbuild/webserver-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/${out_file}
err_file="initialbuild/webserver-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/${err_file}

/bin/echo "${0} `/bin/date`: Building a new webserver" 

/bin/echo "${0} Installing Datastore tools"
${HOME}/providerscripts/datastore/InitialiseDatastoreConfig.sh
${HOME}/providerscripts/datastore/InitialiseAdditionalDatastoreConfigs.sh


${HOME}/utilities/housekeeping/RestoreWholeMachine.sh

/bin/rm -r /var/www/*
/bin/mkdir /var/www/html

/bin/echo "${0} Installing the bespoke application"
${HOME}/application/InstallApplication.sh &

/bin/echo "${0} Installing/Refreshing webserver "
${HOME}/installscripts/InstallWebserver.sh &

/bin/echo "${0} Initialising crontab"
${HOME}/cron/InitialiseCron.sh

if ( [ ! -d ${HOME}/ssl/live/${WEBSITE_URL} ] )
then
        /bin/mkdir -p ${HOME}/ssl/live/${WEBSITE_URL}
fi

/bin/echo "${0} Configuring SSL certificate"
${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/${WEBSITE_URL}/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
/bin/cat ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem >> ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
/bin/chown www-data:www-data ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
/bin/chmod 400 ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
/bin/chown root:root ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem

