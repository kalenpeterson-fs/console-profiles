# == Class: profiles::pe_activemqbroker
#
class profiles::pe_activemqbroker (
    Array $activemq_hubs = ["hub1.example.com","hub2.example.com"]
){
  class { 'puppet_enterprise::profile::amq::broker':
    activemq_hubname => $activemq_hubs,
  }
}
