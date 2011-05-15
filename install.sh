#!/bin/bash

# retstart if not root
if [ "$USER" != 'root' ]; then
  echo "*** You are not logged with root, login with root and restart the script"

  # choose between local adn remote script
  script_path=$(cd ${0%/*} && echo $PWD/${0##*/})
  if [[ "$script_path" =~ /sh$ ]]; then
    su -c "wget --no-check-certificate -q -O - https://github.com/liquidconcept/puppetmaster-install/raw/master/install.sh | sh && exit" -
  else
    su -c "sh $script_path && exit" -
  fi

# run script if root
else
  echo "*** install git..."
  apt-get install -y git

  echo "*** install puppet..."
  apt-get install -y puppet

  echo "*** clone puppetmaster install repository"
  git clone git://github.com/liquidconcept/puppetmaster-install.git ~/puppetmaster-install

  echo "*** run local puppet"
  module_path=$(cd ~/puppetmaster-install && echo $PWD/modules)
  script_path=$(cd ~/puppetmaster-install && echo $PWD/install.pp)

  puppet --modulepath "$module_path" $script_path

  echo "*** remove puppetmaster install repository"
  rm -Rf ~/puppetmaster-install
fi
