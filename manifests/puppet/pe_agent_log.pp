# == Class: profiles::pe_agent_log
#
class profiles::puppet::pe_agent_log (
  Boolean $enable_logdest = false,
  String $logdest         = '/var/log/puppetlabs/puppet/pe-agent.log',
  String $syslog_facility = 'local5',
  String $puppet_confdir  = '/etc/puppetlabs/puppet'
){

  # Enable or disable this profile
  if $enable_logdest {
    $enable_file = file
    $enable_ini  = present
  } else {
    $enable_file = absent
    $enable_ini  = absent
  }

  # OS Based logic
  case $::osfamily {
    'RedHat': {
      $syslog_file     = '/etc/rsyslog.d/pe-puppet.conf'
      $syslog_template = 'rsyslog_pe-agent.epp'
      $logrotate_file  = '/etc/logrotate.d/pe-agent'
    }
    default: {
      fail("Module 'profiles::puppet::pe_agent_log does' not support OS ${::osfamily}")
    }
  }

  # Manage the puppet.conf syslog setting
  pe_ini_setting { 'puppet_conf_syslog_facility':
    ensure  => $enable_ini,
    path    => "${puppet_confdir}/puppet.conf",
    section => 'main',
    setting => 'syslogfacility',
    value   => $syslog_facility,
  }

  # Manage the syslog file
  file { $syslog_file:
    ensure  => $enable_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp ("profiles/puppet/${syslog_template}", {
      'faciity'  => $syslog_facility,
      'log_dest' => $logdest,}),
  }

  # Manage the logrotate.d config for pe-agent
  file { $logrotate_file:
    ensure  => $enable_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp ('profiles/puppet/logrotate_pe-agent.epp', {
      'log_path' => $logdest,}),
  }
}
