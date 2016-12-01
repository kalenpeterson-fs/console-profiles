# == Class: profiles::pe_activemq_hub
#
class profiles::puppet::pe_activemq_hub {
  class { 'puppet_enterprise::profile::amq::hub':
    network_connector_spoke_collect_tag => "pe-amq-network-connectors-for-${::fqdn}",
  }
}
