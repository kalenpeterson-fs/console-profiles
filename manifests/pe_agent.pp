# == Class: profiles::pe_agent
#
class profiles::pe_agent (
){
  class { 'puppet_enterprise::profile::agent': }
}
