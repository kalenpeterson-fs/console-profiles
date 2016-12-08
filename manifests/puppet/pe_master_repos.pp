# == Class: profiles::puppet::pe_master_repos
#
class profiles::puppet::pe_master_repos {

  # List of pe_repo platforms to install
  class { '::pe_repo': }
  class { '::pe_repo::platform::el_7_x86_64': }
  class { '::pe_repo::platform::el_6_x86_64': }
  class { '::pe_repo::platform::el_5_x86_64': }
}
