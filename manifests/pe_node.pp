# == Class: profiles::pe_node
#
class profiles::pe_node (
  String $certificate_authority_host   = "momhost.example.com",
  String $console_host                 = "momhost.example.com",
  String $database_host                = "momhost.example.com",
  Array $mcollective_middleware_hosts  = ["momhost.example.com"],
  String $pcp_broker_host              = "momhost.example.com",
  String $puppetdb_host                = "momhost.example.com",
  String $puppet_master_host           = "momhost.example.com",
  Array $activemq_brokers              = ["puppetvip.example.com"]
){

  # PE Declaration for all nodes
  class { 'puppet_enterprise':
    certificate_authority_host   => $certificate_authority_host,
    console_host                 => $console_host,
    database_host                => $database_host,
    mcollective_middleware_hosts => $mcollective_middleware_hosts,
    pcp_broker_host              => $pcp_broker_host,
    puppetdb_host                => $puppetdb_host,
    puppet_master_host           => $puppet_master_host,
  }

  # Manage the PE Agent
  class { 'puppet_enterprise::profile::agent': }

  # Manage the MCollective Agent
  class { 'puppet_enterprise::profile::mcollective::agent':
    activemq_brokers => $activemq_brokers,
  }
}
