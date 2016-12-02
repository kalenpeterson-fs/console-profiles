# == Class: profiles::pe_mcollective
#
class profiles::puppet::pe_mcollective (
  Array $activemq_brokers = ["puppetcpm01.forsythelab.net"]
){
  class { 'puppet_enterprise::profile::mcollective::agent':
    activemq_brokers => $activemq_brokers,
  }
}
