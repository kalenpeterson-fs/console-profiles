# == Class: profiles::pe_agent
#
class profiles::puppet::pe_agent (
){
  class { 'puppet_enterprise::profile::agent': }
}
