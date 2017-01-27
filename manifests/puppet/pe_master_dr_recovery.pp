# == Class: profiles::puppet::pe_master_dr_recovery
#
class profiles::puppet::pe_master_dr_recovery (
    $pe_mom_ip_address  = '10.227.100.70',
    $pe_mom_fqdn        = 'c6ppmav10.forsythelab.net',
    $remote_user        = 'puppetdr',
    $remote_user_key    = '/home/puppetdr/.ssh/id_rsa',
    $working_dir        = '/opt/puppetlabs/dr_recovery',
){

  # Variables
  $backup_script   = "${working_dir}/pe_master_backup.sh"
  $restore_script  = "${working_dir}/pe_master_restore.sh"
  $backup_filename = "dr_recovery.${::hostname}.tar.gz"
  $restore_command = "sudo /tmp/pe_master_restore.sh -f /tmp/${backup_filename}"

  # Manage the working dir for everything we'll do here
  file { 'working_dir':
    ensure => directory,
    path   => $working_dir,
    owner  => $remote_user,
    group  => 'root',
    mode   => '0755',
  }

  # Deploy the backup script
  file { 'dr_backup_script':
    ensure  => file,
    path    => $backup_script,
    source  => 'puppet:///modules/profiles/puppet/pe_master_backup.sh',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => File['working_dir'],
  }

  # Deploy the restore script
  file { 'dr_restore_script':
    ensure  => file,
    path    => $restore_script,
    source  => 'puppet:///modules/profiles/puppet/pe_master_restore.sh',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => File['working_dir'],
  }

  # Validate that we are NOT the Primary MoM
  if $::fqdn != $pe_mom_fqdn {

    notify { "Current FQDN is NOT the Primary MoM, Processing a DR Recovery": }

    # Detect and activate recovery
    exec { 'dr_recovery':
      command   => "touch ${working_dir}/activated",
      path      => '/bin:/usr/bin',
      logoutput => true,
      require   => [ File['dr_backup_script'], File['dr_restore_script']],
      onlyif    => "ping -c 4 -W 5 -t 5 ${pe_mom_ip_address}",
      creates   => "${working_dir}/recovered",
      notify    => Exec['backup_dr_mom'],
    }

    # Perform the Backup on the DR Master
    exec { 'backup_dr_mom':
      command     => "su ${remote_user} -c 'sudo ${backup_script} -d ${working_dir} -n ${backup_filename}'",
      path        => '/bin:/usr/bin',
      logoutput   => true,
      refreshonly => true,
      notify      => Exec['scp_restore_script'],
    }

    # Copy the Restore Script to Primary
    exec { 'scp_restore_script':
      command     => "scp -p -o StrictHostKeyChecking=no -i ${remote_user_key} ${restore_script} ${remote_user}@${pe_mom_ip_address}:/tmp",
      path        => '/bin:/usr/bin',
      logoutput   => true,
      onlyif      => "ssh -o ConnectTimeout=2 -o ConnectionAttempts=2 -o StrictHostKeyChecking=no -i ${remote_user_key} ${remote_user}@${pe_mom_ip_address} 'echo >/dev/null' >/dev/null",
      refreshonly => true,
      notify      => Exec['scp_backup'],
    }

    # Copy the Backup to Primary
    exec { 'scp_backup':
      command     => "scp -p -o StrictHostKeyChecking=no -i ${remote_user_key} ${working_dir}/${backup_filename} ${remote_user}@${pe_mom_ip_address}:/tmp",
      path        => '/bin:/usr/bin',
      logoutput   => true,
      onlyif      => "ssh -o ConnectTimeout=2 -o ConnectionAttempts=2 -o StrictHostKeyChecking=no -i ${remote_user_key} ${remote_user}@${pe_mom_ip_address} 'echo >/dev/null' >/dev/null",
      refreshonly => true,
      notify      => Exec['restore_backup'],
    }

    # Execure the Backup Restore
    exec { 'restore_backup':
      command     => "ssh -o StrictHostKeyChecking=no -i ${remote_user_key} ${remote_user}@${pe_mom_ip_address} '${restore_command}'; touch ${working_dir}/recovered",
      path        => '/bin:/usr/bin',
      timeout     => '600',
      logoutput   => true,
      refreshonly => true,
      notify      => Exec['cleanup_restore'],
    }

    # Perform Cleanup on Primary Master
    exec { 'cleanup_restore':
      command     => "ssh -o StrictHostKeyChecking=no -i ${remote_user_key} ${remote_user}@${pe_mom_ip_address} 'rm -f /tmp/pe_master_restore.sh; rm -f /tmp/${backup_filename}'",
      path        => '/bin:/usr/bin',
      logoutput   => true,
      refreshonly => true,
    }
  }
}
