Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }

package{"puppetmaster-passenger":
  ensure => present,
}