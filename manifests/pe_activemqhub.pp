# == Class: profiles::pe_activemqhub
#
class profiles::pe_activemqhub {
  class { 'puppet_enterprise::profile::amq::hub':
    network_connector_spoke_collect_tag => "pe-amq-network-connectors-for-${::fqdn}",
  }
}
