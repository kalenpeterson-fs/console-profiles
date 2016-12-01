# == Class: profiles::pe_puppetdb
#
class profiles::puppet::pe_puppetdb {
  class { '::puppet_enterprise::profile::puppetdb': }
}
