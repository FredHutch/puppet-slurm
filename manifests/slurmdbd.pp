class slurm::slurmdbd(
  $dbdStorageHost = '',
  $dbdStorageLoc = '',
  $dbdHost = '',
  $dbdconfig = "$slurm::configdir/slurmdbd.conf",
  $ArchiveDir='/var/spool/slurm-llnl/slurm-event-archive',
  $ArchiveEvents='no',
  $ArchiveJobs='no',
  $ArchiveResvs='no',
  $ArchiveScript='',
  $ArchiveSteps='no',
  $ArchiveSuspend='no',
  $PurgeEventAfter='',
  $PurgeJobAfter='',
  $PurgeResvAfter='',
  $PurgeStepAfter='',
  $PurgeSuspendAfter=''
) inherits slurm {
  if $ArchiveEvents == 'yes' {
    file { $ArchiveDir:
      path   => "$ArchiveDir",
      ensure => directory,
      owner  => 'slurm',
      group  => 'slurm',
      mode   => '0644';
    }
  }
  file {
    $dbdconfig:
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0644',
      content => template("slurm/${dbdconfig}.erb");
  }
  package { "slurm-llnl-slurmdbd":
    ensure => present,
  }
  service { 'slurmdbd':
    ensure   => 'running',
    enable   => true,
    provider => 'upstart'
  }
  exec { "cluster_add":
    command => "sacctmgr --immediate add cluster ${ClusterName}",
    path    => "/bin:/usr/bin:/usr/sbin",
    unless  => "sacctmgr --noheader list cluster ${ClusterName} format=Cluster |/bin/grep ${ClusterName}"
  }
}
