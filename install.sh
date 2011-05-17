#!/bin/bash

# retstart if not root
if [ "$USER" != 'root' ]
then
  echo "*** You are not logged with root, login with root and restart the script"

  # choose between local adn remote script
  script_path=$(cd $(dirname $0) && echo $PWD/$(basename $0))
  su -c "sh $script_path && exit" -

# run script if root
else
  echo "*** install git..."
  apt-get install -y git

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
      sed -i "s/$ipaddress/$ipaddress\t$hostname.$domain/g" /etc/hosts
    fi
  fi

  echo "*** configue master host"
  if [ $(grep -c -E "localhost.+puppet" /etc/hosts) -eq 0 ]
  then
    sed -i "s/localhost/localhost\tpuppet/g" /etc/hosts
  fi

  script_path=$(cd $(dirname $0) && echo $PWD/install.sh)
  script_dir=$(dirname $script_path)
  if [ -e $script_path ]
  then
    echo "*** use local puppetmaster install repository: $(dirname $script_path)"
  else
    echo "*** clone puppetmaster install repository"
    git clone git://github.com/liquidconcept/puppetmaster-install.git /tmp/puppetmaster-install
    script_path=$(cd /tmp/puppetmaster-install && echo $PWD/install.pp)
  fi

  if [ ! -d /etc/puppet/staging -o ! -d /etc/puppet/stable ]
  then
    echo "*** clone puppetmaster config reposiroty"
    mkdir -p /etc/puppet
    read -p "Puppetmaster configuration repository (with a staging & stable branch): " repo
    if [ "$(echo $repo | sed 's%^git@%%')" != "$repo" ]
    then
      mkdir -p $HOME/.ssh
      chmod 700 $HOME/.ssh
      ssh-keygen -N "" -f $HOME/.ssh/puppetmaster_install_id
      echo "Copy follwing public key to authorize to clone your puppetmaster configuration repository (enter when done or if you already have an access key configured for root user):"
      echo "--------------------"
      cat $HOME/.ssh/puppetmaster_install_id.pub
      echo "--------------------"
      read is_done
    fi
    if [ ! -d /etc/puppet/staging ]
    then
      git clone -b staging $repo /etc/puppet/staging
    fi
    if [ ! -d /etc/puppet/stable ]
    then
      git clone -b stable $repo /etc/puppet/stable
    fi
    if [ -f $HOME/.ssh/puppetmaster_install_id.pub ]
    then
      rm $HOME/.ssh/puppetmaster_install_id
    fi
  fi


  echo "*** install puppetmaster..."
  apt-get install -y puppetmaster-passenger

  echo "*** install puppet..."
  apt-get install -y puppet

  echo "*** configure puppet master & puppet agent"
  service apache2 stop
  cat $script_dir/files/puppet.conf > /etc/puppet/puppet.conf
  sed -i -r "s%SSLCARevocationFile.+%SSLCARevocationPath     /var/lib/puppet/ssl/ca/crl%g" /etc/apache2/sites-available/puppetmaster
  service apache2 start

  echo "*** run puppet..."
  puppet agent --test

  if [ -d /tmp/puppetmaster-install ]
  then
    echo "*** remove puppetmaster install repository"
    rm -Rf /tmp/puppetmaster-install
  fi
fi

