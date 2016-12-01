# == Class: profiles::pe_certificate_authority
#
class profiles::pe_certificate_authority {
  class { '::puppet_enterprise::profile::certificate_authority': }
}
