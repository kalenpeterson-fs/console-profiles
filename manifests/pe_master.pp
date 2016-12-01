# == Class: profiles::pe_master
#
class profiles::pe_master (
  String $pe_repo_master               = 'puppetmomvip.example.com',
  Array $activemq_brokers              = ["puppetvip.example.com"],
  String $r10k_remote                  = "git@github.com:ljhooker/home_puppet.git",
  String $r10k_private_key             = "/opt/puppetlabs/puppet/id_rsa",
  Boolean $file_sync_enabled           = true,
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
    file_sync_enabled           => $file_sync_enabled,
    code_manager_auto_configure => $code_manager_auto_configure,
  }

  # PE Master MCollective config
  class { '::puppet_enterprise::profile::master::mcollective': }
  class { '::puppet_enterprise::profile::mcollective::peadmin':
    activemq_brokers => $activemq_brokers,
  }
}
