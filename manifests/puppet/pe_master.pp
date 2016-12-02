# == Class: profiles::pe_master
#
class profiles::puppet::pe_master (
  String $pe_repo_master               = 'puppetcpm01.forsythelab.net',
  Array $activemq_brokers              = ["puppetcpm01.forsythelab.net"],
  String $r10k_remote                  = "git@c6glabv01.forsythelab.net:kpeterson/c6ppmav10-control.git",
  String $r10k_private_key             = "/etc/puppetlabs/puppetserver/ssh/id_rsa",
  Boolean $code_manager_auto_configure = true
){

  # PE Repo Config
  class { '::pe_repo':
    master => $pe_repo_master,
  }

  # Define Supported Agent Platforms
  class { '::pe_repo::platform::el_7_x86_64': }

  # PE Master config
  class { '::puppet_enterprise::profile::master':
    r10k_remote                 => $r10k_remote,
    r10k_private_key            => $r10k_private_key,
    code_manager_auto_configure => $code_manager_auto_configure,
  }

  # PE Master MCollective config
  class { '::puppet_enterprise::profile::master::mcollective': }
  class { '::puppet_enterprise::profile::mcollective::peadmin':
    activemq_brokers => $activemq_brokers,
  }
}
