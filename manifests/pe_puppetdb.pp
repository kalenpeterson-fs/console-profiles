# == Class: profiles::pe_puppetdb
#
class profiles::pe_puppetdb {
  class { '::puppet_enterprise::profile::puppetdb': }
}
