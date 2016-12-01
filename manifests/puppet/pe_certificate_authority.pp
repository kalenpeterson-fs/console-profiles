# == Class: profiles::pe_certificate_authority
#
class profiles::puppet::pe_certificate_authority {
  class { '::puppet_enterprise::profile::certificate_authority': }
}
