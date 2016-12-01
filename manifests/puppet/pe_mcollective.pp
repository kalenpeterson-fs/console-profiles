# == Class: profiles::pe_mcollective
#
class profiles::puppet::pe_mcollective (
  Array $activemq_brokers = ["puppetvip.example.com"]
){
  class { 'puppet_enterprise::profile::mcollective::agent':
    activemq_brokers => $activemq_brokers,
  }
}
