class slurm::pam () inherits slurm::params {
  package{
    'libpam-slurm':
      ensure => 'installed';
  }
  augeas { "pam_slurm":
    context => "/files/etc/pam.d/common-account/",
    changes => [
        'set 9999/type account',
        'set 9999/control required',
        'set 9999/module pam_slurm.so',
    ],
    onlyif => "match *[type='account'][module='pam_slurm.so'][control='required'] size == 0",
  }
}
