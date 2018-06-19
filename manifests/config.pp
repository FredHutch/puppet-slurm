#
class slurm::config inherits slurm {
  $nodes = hiera_hash( "slurm::nodes" )
  $partitions = hiera_hash( "slurm::partitions" )
  $JobSubmitPlugins = $slurm::JobSubmitPlugins
  /*
  # This fails because we have an ldap entry for slurm
  user { 'slurm':
      ensure    => present,
      uid       => '6281',
      allowdupe => true,
      comment   => 'SLURM daemon user',
      gid       => 'slurm',
      home      => '/var/log/slurm-llnl',
      shell     => '/bin/bash';
  }
  */
  augeas{ 'slurm-account':
    context => '/files/etc/passwd',
    changes => [
      'set slurm/password x',
      'set slurm/uid 6281',
      'set slurm/gid 6281',
      'set slurm/name slurm daemon user',
      'set slurm/home /var/log/slurm-llnl',
      'set slurm/shell /bin/bash'
    ]
  }
  group { 'slurm':
      ensure     => present,
      gid        => '6281',
      allowdupe  => true
  }

  file {
    $configdir :
      ensure => directory,
      owner   => 'slurm',
      group   => 'root',
      mode    => '0755';
    $rundir :
      ensure => directory,
      owner   => 'slurm',
      group   => 'root',
      mode    => '0755';
    $spooldir :
      ensure => directory,
      owner   => 'slurm',
      group   => 'root',
      mode    => '0755';
    $config:
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0644',
      content => template("slurm/${config}.erb");
    $defaults:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("slurm/${defaults}.erb");
  }
  if $TaskProlog != '' {
    file { $TaskProlog:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("slurm/$TaskProlog.erb")
    }
  }
  if $TaskEpilog != '' {
    file { $TaskEpilog:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("slurm/$TaskEpilog.erb")
    }
  }
  if $Prolog != '' {
    file { $Prolog:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("slurm/$Prolog.erb")
    }
  }
  if $Epilog != '' {
    file { $Epilog:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("slurm/$Epilog.erb")
    }
  }
  if $PrologSlurmctld != '' {
    file { $PrologSlurmctld:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("slurm/$PrologSlurmctld.erb")
    }
  }
  if $EpilogSlurmctld != '' {
    file { $EpilogSlurmctld:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("slurm/$EpilogSlurmctld.erb")
    }
  }
  if $job_checkpoint_dir != '' {
    file { $job_checkpoint_dir:
      ensure  => directory,
      owner   => 'slurm',
      group   => 'root',
      mode    => '0755',
      require => File[ $spooldir ]
    }
  }
  if $plugstack_conf != '' {
    file { $plugstack_conf:
      ensure  => directory,
      owner   => 'slurm',
      group   => 'root',
      mode    => '0755',
      require => File[ $configdir ]
    }
  }
  #
  # Legacy crap down here:
  #
  # use-env spank plugin configuration
  #
  file{
    "$configdir/environment":
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
    "$configdir/environment/default":
      ensure   => 'present',
      require  => File[ "$configdir/environment" ],
      owner    => 'root',
      group    => 'root',
      mode     => '0755',
      content  => template("slurm/spank-use-env-default.erb");
  }
}
