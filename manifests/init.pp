class slurm (
  $configdir = $slurm::params::configdir,
  $rundir = $slurm::params::rundir,
  $spooldir = $slurm::params::spooldir,
  $service = $slurm::params::service,
  $config = $slurm::params::config,
  $defaults = $slurm::params::defaults,

  $job_checkpoint_dir = $slurm::params::job_checkpoint_dir,
  $plugstack_conf = $slurm::params::plugstack_conf,

  $ClusterName = $slurm::params::ClusterName,
  $ControlMachine = $slurm::params::ControlMachine,
  $TaskProlog = $slurm::params::TaskProlog ,
  $TaskEpilog = $slurm::params::TaskEpilog ,
  $Prolog = $slurm::params::Prolog ,
  $Epilog = $slurm::params::Epilog ,
  $PrologSlurmctld = $slurm::params::PrologSlurmctld ,
  $EpilogSlurmctld = $slurm::params::EpilogSlurmctld ,
  $JobSubmitPlugins = $slurm::JobSubmitPlugins
) inherits slurm::params {

  package{
    $libslurm :
      ensure => 'installed';
    'slurm-llnl':
      ensure => 'installed';
    'slurm-llnl-basic-plugins':
      ensure => 'installed';
  }
  include slurm::munge
}

