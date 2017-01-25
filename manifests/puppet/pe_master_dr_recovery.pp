# == Class: profiles::puppet::pe_master_dr_recovery
#
class profiles::puppet::pe_master_dr_recovery (
    Boolean $enable_autorecover = true,
    String $pe_mom_ip_address   = '10.227.100.70',
    String $remote_user         = 'root',
    String $remote_user_key     = '/path/to/private/key.id_rsa',
    String $script_dir          = '/opt/puppetlabs/server/bin',
    String $working_dir         = '/opt/puppetlabs/dr_recovery'
){

  # Manage the working dir everything we'll do here
  file { 'working_dir':
    ensure => directory,
    path   => $working_dir,
    before => Exec['dr_recovery'],
  }

  # Deploy the bakcup script
  file { 'backup_script':
    ensure  => file,
    path    => "${working_dir}/pe_master_backup.sh"
    source  => 'puppet:///modules/profiles/pe_master_backup.sh'
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => File['working_dir'],
  }

  # Detect and activate recovery
  exec { 'dr_recovery':
    command => "/bin/touch ${working_dir}/activated",
    creates => "${working_dir}/activated",
    onlyif  => "ping -c 4 -W 5 -t 5 ${pe_mom_ip_address}",
  }

  exec { 'backup_dr_mom':
    command => "${working_dir}/pe_master_backup.sh -d ${working_dir}"
  }
}
