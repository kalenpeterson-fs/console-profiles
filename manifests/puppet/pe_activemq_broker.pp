# == Class: profiles::pe_activemq_broker
#
class profiles::puppet::pe_activemq_broker (
    Array $activemq_hubs = ["c6ppmav11.forsythelab.net","c6ppmav13.forsythelab.net"]
){
  class { 'puppet_enterprise::profile::amq::broker':
    activemq_hubname => $activemq_hubs,
  }
}
