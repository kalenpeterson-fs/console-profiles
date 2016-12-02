# == Class: profiles::pe_agent
#
class profiles::puppet::pe_agent (
  Boolean $enable_logdest = false,
  String $logdest         = '/var/log/puppetlabs/puppet/pe-agent.log',
  Boolean $enable_debug   = false,
  Boolean $enable_verbose = false,
){
  class { 'puppet_enterprise::profile::agent': }

  # Manage the puppet sysconfig file
  # Allow the --logdest parameter to be specified here
  file { '/etc/sysconfig/puppet':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['puppet_enterprise::profile::agent'],
    notify  => Service['puppet-agent']
    content => epp('profiles/puppet/etc_sysconfig_puppet', {
      'enable_logdest' => $enable_logdest,
      'logdest'        => $logdest,
      'enable_debug'   => $enable_debug,
      'enable_verbose' => $enable_verbose}),
  }

  # If the pe-agent log is enabled, create a logrotate.d file for it
  $pe_agent_logrotate = $enable_logdest ? {
    true    => file,
    default => absent,
  }
  file {'/etc/logrotate.d/pe-agent':
    ensure  => $pe_agent_logrotate,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp ('profiles/puppet/logrotate_pe-agent.pp', {
      'log_path' => $logdest,}),
  }
}
