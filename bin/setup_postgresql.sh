#!/bin/bash
#

if [ 0 != $UID ] ; then
  echo "Please run this script as sudo"
  exit 1
fi

#
# Reset default user password to empty for development server only
#
sudo -u postgres psql -c "alter user postgres with password '';"

#
# Setup current user
#
sudo -u postgres createuser --superuser $SUDO_USER
sudo -u postgresl psql -c "alter user $SUDO_USER with password '';"
createdb $SUDO_USER

exit 0

