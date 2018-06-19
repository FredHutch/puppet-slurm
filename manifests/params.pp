class slurm::params {
  $libslurm = 'libslurm26'
  $TaskProlog = ''
  $TaskEpilog = ''
  $Prolog = ''
  $Epilog = ''
  $PrologSlurmctld = ''
  $EpilogSlurmctld = ''
  $checkpoint_type = ''
  $plugstack_conf = ''
  $JobSubmitPlugins = ''
  
  $ClusterName = 'cluster'
  $ControlMachine = ''

  case $::osfamily {
    'Debian': {
      $service = 'slurm-llnl'
      $home = '/var/log/slurm-llnl'
      $configdir = '/etc/slurm-llnl'
      $spooldir = "/var/spool/${service}"
      $rundir = "/var/run/${service}"
      $config = "$configdir/slurm.conf"
      $defaults = '/etc/default/slurm-llnl'
      if $checkpoint_type != '' {
        $job_checkpoint_dir = "$spooldir/checkpoint"
      }
    }
  }
}
