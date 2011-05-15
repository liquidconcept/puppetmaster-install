#!/bin/bash

# retstart if not root
if [ "$USER" != 'root' ]; then
  echo "You are not logged with root, login with root and restart the script"

  # choose between local adn remote script
  script_path=$(cd ${0%/*} && echo $PWD/${0##*/})
  if [[ "$script_path" =~ /sh$ ]]; then
    su -c "wget --no-check-certificate -q -O - https://github.com/liquidconcept/puppetmaster-install/raw/master/install.sh | sh && exit" -
  else
    su -c "sh $script_path && exit" -
  fi

# run script if root
else

  echo "install git..."
  apt-get install -y git

  echo "install puppet..."
  apt-get install -y puppet

  echo "clone puppetmaster install repository"
  git clone https://github.com/liquidconcept/puppetmaster-install ~/puppetmaster-install

  echo "remove puppetmaster install repository"
  rm -Rf ~/puppetmaster-install
fi
