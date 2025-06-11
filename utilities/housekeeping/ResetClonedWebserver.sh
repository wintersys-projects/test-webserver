HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"

/bin/rm ${HOME}/runtime/FIREWALL-ACTIVE

USER_NAME="`/usr/bin/awk -F: '{ print $1}' /etc/passwd | /bin/grep "X*X"`"

original_user="`/bin/ls -l /home | /bin/grep "X*X" | /usr/bin/awk '{print $NF}' | /bin/grep -v "${USER_NAME}"`"

if ( [ ! -d ${HOME}/ssl/live/${WEBSITE_URL} ] )
then
  /bin/mkdir -p ${HOME}/ssl/live/${WEBSITE_URL}
fi

/bin/mv /home/${original_user}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}
/bin/mv /home/${original_user}/ssl/live/${WEBSITE_URL}/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}

/bin/chown www-data:www-data ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
/bin/chown www-data:www-data ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem

/bin/chmod 400 ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
/bin/chmod 400 ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem

webserver_config="`/bin/cat ${HOME}/runtime/WEBSERVER_CONFIG_LOCATION.dat`"

/bin/sed -i "s/${original_user}/${USER_NAME}/g" ${webserver_config}

/bin/rm -r /home/${original_user}

${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS} &


