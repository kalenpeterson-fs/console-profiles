# == Class: profiles::pe_infrastructure
#
class profiles::puppet::pe_infrastructure (
  String $certificate_authority_host   = "c6ppmav10.forsythelab.net",
  String $console_host                 = "c6ppmav10.forsythelab.net",
  String $database_host                = "c6ppmav10.forsythelab.net",
  Array $mcollective_middleware_hosts  = ["c6ppmav10.forsythelab.net"],
  String $pcp_broker_host              = "c6ppmav10.forsythelab.net",
  String $puppetdb_host                = "c6ppmav10.forsythelab.net",
  String $puppet_master_host           = "c6ppmav10.forsythelab.net",
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
}
