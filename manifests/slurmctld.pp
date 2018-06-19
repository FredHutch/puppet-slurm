class slurm::slurmctld() {
  service { 'slurmctld':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
  augeas { "slurmsudo":
    context => "/files/etc/sudoers",
    changes => [
      "set spec[ user = 'slurm' ]/user slurm",
      "set spec[ user = 'slurm' ]/host_group/host ALL",
      "set spec[ user = 'slurm' ]/host_group/command[1]/runas_user root",
      "set spec[ user = 'slurm' ]/host_group/command[1]/tag NOPASSWD",
      "set spec[ user = 'slurm' ]/host_group/command[1] /bin/rm",
      "set spec[ user = 'slurm' ]/host_group/command[2] /bin/mkdir",
      "set spec[ user = 'slurm' ]/host_group/command[3] /bin/chown",
    ]
  }
}
