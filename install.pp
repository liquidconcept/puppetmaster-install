Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }

import "common"

file {"/etc/puppet/puppet.conf":
  ensure => present,
  content => "[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
templatedir=$confdir/templates
prerun_command=/etc/puppet/etckeeper-commit-pre
postrun_command=/etc/puppet/etckeeper-commit-post

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN 
ssl_client_verify_header = SSL_CLIENT_VERIFY

[agent]
environment=staging

[stable]
manifest=/etc/puppet/stable/site.pp
modulepath=/etc/puppet/stable/modules:/etc/puppet/stable/site-modules

[staging]
manifest=/etc/puppet/staging/site.pp
modulepath=/etc/puppet/staging/modules:/etc/puppet/staging/site-modules

",
}

package{"puppetmaster-passenger":
  ensure => present,
  require => File["/etc/puppet/puppet.conf"],
}

package{"puppet":
  ensure => present,
  require => File["/etc/puppet/puppet.conf"],
}

exec{"puppet agent --server $fqdn":
  require => Package["puppetmaster-passenger", "puppet"],
}
