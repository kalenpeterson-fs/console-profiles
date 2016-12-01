# == Class: profiles::pe_orchestrator
#
class profiles::puppet::pe_orchestrator {
  class { '::puppet_enterprise::profile::orchestrator': }
}
