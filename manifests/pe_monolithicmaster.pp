# == Class: profiles::pe_monolithicmaster
#
class profiles::pe_monolithicmaster (
  String $pe_repo_master               = 'puppet.example.com',
  Array $activemq_brokers              = ["puppet.example.com"],
  String $r10k_remote                  = "git@github.com:ljhooker/home_puppet.git",
  String $r10k_private_key             = "/opt/puppetlabs/puppet/id_rsa",
  Boolean $file_sync_enabled           = true,
  Boolean $code_manager_auto_configure = true
){
  # PE Repo Config
  class { '::pe_repo':
    master => $pe_repo_master,
  }

  # Define Supported Platforms
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

  # Other Monolithic PE Services
  class { '::puppet_enterprise::profile::certificate_authority':}
  class { '::puppet_enterprise::license':}
  class { '::pe_console_prune':}
  class { '::puppet_enterprise::profile::console':}
  class { '::puppet_enterprise::profile::orchestrator':}
  class { '::puppet_enterprise::profile::puppetdb':}
}
