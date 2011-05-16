#!/bin/bash

# retstart if not root
if [ "$USER" != 'root' ]
then
  echo "*** You are not logged with root, login with root and restart the script"

  # choose between local adn remote script
  script_path=$(cd ${0%/*} && echo $PWD/${0##*/})
  if [ "$script_path" = "/bin/sh" -o "$script_path" = "sh" ]
  then
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

  fqdn=$(facter fqdn)
  if [ "$fqdn" = "" ]
  then
    echo "*** configure fqdn"
    hostname=$(facter hostname)
    ipaddress=$(facter ipaddress)
    read -p "hostname is '$hostname', enter domain: " domain
    while :
    do
      read -p "fqdn is now '$hostname.$domain', enter to continue or type another domain: " domain2
      if [ "$domain2" = "" ]
      then
        break
      fi
      domain=$domain2
    done
    if [ $(grep -c -E "$ipaddress.+$hostname.$domain" /etc/hosts) -eq 0 ]
    then
      sed -i "s/$hostname/$hostname.$domain\t$hostname/g" /etc/hosts
    fi
  fi

  script_path=$(cd ${0%/*} && echo $PWD/install.pp)
  if [ -e $script_path ]
  then
    echo "*** use local puppetmaster install repository: $(dirname $script_path)"
  else
    echo "*** clone puppetmaster install repository"
    git clone git://github.com/liquidconcept/puppetmaster-install.git ~/puppetmaster-install
    script_path=$(cd ~/puppetmaster-install && echo $PWD/install.pp)
  fi
  module_path=$(cd $(dirname $script_path) && echo $PWD/modules)

  echo "*** run local puppet"
  puppet --modulepath "$module_path" $script_path

  echo "*** remove puppetmaster install repository"
  rm -Rf ~/puppetmaster-install
fi

