class slurm::munge () inherits slurm {
  package { 'munge':
          ensure => present ;
  }
  file {
    '/etc/munge':
      owner  => 'munge',
      group  => 'root',
      mode   => 0700,
      ensure => 'directory';
    '/etc/munge/munge.key':
      owner   => "munge",
      group   => "root",
      mode    => 0400,
      source  => "puppet:///modules/slurm/munge.key",
      require => Package[ 'munge' ],
      notify  => Service[ 'munge' ];
    '/etc/default/munge':
      owner   => "root",
      group   => "root",
      mode    => 0644,
      source  => "puppet:///modules/slurm/etc/default/munge",
      require => Package[ 'munge' ],
      notify  => Service[ 'munge' ];
    '/var/log/munge':
      owner  => 'munge',
      group  => 'root',
      mode   => 0700,
      ensure => 'directory';
    '/var/lib/munge':
      owner  => 'munge',
      group  => 'root',
      mode   => 0700,
      ensure => 'directory';
    '/var/run/munge':
      owner  => 'munge',
      group  => 'root',
      mode   => 0711,
      ensure => 'directory';
  }
  service { 'munge':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
  }
}

