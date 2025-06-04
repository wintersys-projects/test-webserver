#!/bin/sh


/bin/echo "${0} Installing Datastore tools"
${HOME}/providerscripts/datastore/InitialiseDatastoreConfig.sh
${HOME}/providerscripts/datastore/InitialiseAdditionalDatastoreConfigs.sh


${HOME}/utilities/housekeeping/RestoreWholeMachine.sh


/bin/echo "${0} Installing the bespoke application"
${HOME}/application/InstallApplication.sh

