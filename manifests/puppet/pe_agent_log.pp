# == Class: profiles::pe_agent_log
#
class profiles::puppet::pe_agent_log (
  Boolean $enable_logdest = true,
  String $logdest         = '/var/log/puppetlabs/puppet/pe-agent.log',
  String $syslog_facility = 'local5',
  String $puppet_confdir  = '/etc/puppetlabs/puppet'
){

  # OS Based logic
  case $::osfamily {
    'RedHat': {
      $syslog_file     = '/etc/rsyslog.d/pe-puppet.conf'
      $syslog_template = 'rsyslog_pe-agent.epp'
      $logrotate_file  = '/etc/logrotate.d/pe-agent'
      $syslog_service  = 'rsyslog'
    }
    default: {
      fail("Module 'profiles::puppet::pe_agent_log does' not support OS ${::osfamily}")
    }
  }

  # Enable or disable this profile
  if $enable_logdest {

    notify { "Enabling PE Logdest": }
    $enable_file = file
    $enable_ini  = present

    # Manage the syslog service if it's running
    #  This should be removed when a syslog profile has been
    #  added to the base
    service  { $syslog_service:
      ensure    => 'running',
      subscribe => File[$syslog_file],
    }
  } else {
    notify { "Disabling PE Logdest": }
    $enable_file = absent
    $enable_ini  = absent
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
      'facility' => $syslog_facility,
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
