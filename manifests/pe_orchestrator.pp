# == Class: profiles::pe_orchestrator
#
class profiles::pe_orchestrator {
  class { '::puppet_enterprise::profile::orchestrator': }
}
