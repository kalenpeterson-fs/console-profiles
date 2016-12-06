# == Class: profiles::puppet::pe_master_backup
#
class profiles::puppet::pe_master_backup (
    String $backup_dir            = '/opt/puppetlabs/puppet_backups',
    Array $backup_hour            = [2],
    String $backup_minute         = '0',
    String $backup_retention_days = '14',
    Boolean $enable               = true
){

  # Manage Enabling or Disabling backup
  if $enable {
    $ensure_script = file
    $ensure_cronjob = present

    # Manage retention of backup files
    tidy { 'pe_master_backup_retention':
      path    => $backup_dir,
      age     => $backup_retention_days,
      type    => 'ctime',
      recurse => 1,
      matches => [ 'pe_backup.*.tar.gz'],
    }
  } else {
    $ensure_script = absent
    $ensure_cronjob = absent
  }
  file { $backup_dir:
    ensure => directory,
  }

  # Manage the  Backup Script
  file { 'pe_master_backup_script':
    ensure  => $ensure_script,
    path    => "${backup_dir}/pe_master_backup.sh",
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/profiles/puppet/pe_master_backup.sh',
    require => File[$backup_dir],
  }

  # Manage the Restore Script
  file { 'pe_master_restore_script':
    ensure  => $ensure_script,
    path    => "${backup_dir}/pe_master_restore.sh",
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/profiles/puppet/pe_master_restore.sh',
    require => File[$backup_dir],
  }

  # Manage the cronjob to run pe_master_backup.sh
  cron { 'pe_master_backup_cronjob':
    ensure  => $ensure_cronjob,
    command => "'${backup_dir}/pe_master_backup.sh' -d '${backup_dir}'",
    user    => 'root',
    hour    => $backup_hour,
    minute  => $backup_minute,
  }
}
