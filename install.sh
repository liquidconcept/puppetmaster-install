#!/bin/bash

# retstart if not root
if [ "$USER" != 'root' ]; then
  echo "You are not logged with root, login with root and restart the script"
  su -c "wget --no-check-certificate -q -O - https://github.com/liquidconcept/puppetmaster-install/raw/master/install.sh | sh && exit" -
# run script if root
else

  echo "install git..."
  apt-get install -y git

  echo "install puppet..."
  apt-get install -y puppet

fi
