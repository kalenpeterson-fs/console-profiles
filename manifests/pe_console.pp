# == Class: profiles::pe_console
#
class profiles::pe_console {
  class { '::puppet_enterprise::profile::console': }
  class { '::puppet_enterprise::license': }
  class { '::pe_console_prune': }
}
