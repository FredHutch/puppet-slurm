#Slurm

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with mysql](#setup)
    * [What mysql affects](#what-mysql-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with mysql](#beginning-with-mysql)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

This module configures SchedMD's Slurm software on nodes

##Module Description

This module installs the software, creates the configuration, and the
Slurm database (including configuring MySQL databases).

##Setup

###Node and Controller Installation

A Slurm cluster is made up of a controller, daemons, and the
database connector. 

> This version will need all three- there is no
> option for a cluster without the database back-end.

Most systems should only declare the `slurm` class:

```puppet
class { 'slurm':
  ClusterName: 'mycluster',
  ControlMachine: 'slurmctld.foo.org'
}
```

Where `slurmctld.foo.org` is the hostname of the host running `slurmctld`.  No other special configuration is required for the controller host.

###Database Configuration

The host running the `dbd` connector needs to include the `mysql` class and add the database using its methods.  Below is a hiera example where the controller and DBD run on the same host (`slurmctld`) and store the data in a database `mycluster_acct_db` :

```yaml
slurm::slurmdbd::dbdStorageHost: 'slurmctld'
slurm::slurmdbd::dbdHost: 'slurmctld'
slurm::slurmdbd::dbdStorageLoc: 'mycluster_acct_db'

mysql::server:
    root_password: 'password'

mysql::server::override_options:
    mysqld:
        bind-address: '0.0.0.0'

mysql::server::users:
    'slurm@localhost':
        ensure: 'present'
mysql::server::databases:
    'mycluster_acct_db':
        ensure: 'present'
mysql::server::grants:
    'slurm@slurmctld/mycluster_acct_db':
        ensure: 'present'
        options:
            - 'GRANT'
        privileges:
            - 'ALL'
        table: 'mycluster_acct_db.*'
        user: 'slurm@slurmctld'
    'slurm@localhost/mycluster_acct_db':
        ensure: 'present'
        options:
            - 'GRANT'
        privileges:
            - 'ALL'
        table: 'mycluster_acct_db.*'
        user: 'slurm@localhost'
```

##Configuring the Cluster

The Slurm cluster is configured via hiera.  This module uses the
hiera_hash function to obtain the necessary information from your
hiera database

###Defining Nodes

Nodes are configured in a hash (dictionary?) containing an entry for
each of the nodes in your cluster:

```yaml
slurm::nodes:
    'node_name': 
        Boards:
        CoresPerSocket:
        CPUs: 2
        Feature:
            - 'feature_1'
            - 'feature_2'
            - 'feature_3'
        Gres:
            - 'resource_1'
            - 'resource_2'
        NodeAddr:
        NodeName: 'node_name'
        Port: 6817
        RealMemory:
        Sockets:
        SocketsPerBoard:
        ThreadsPerCore:
        TmpDisk:
        Weight:
```

This example shows all of the available parameters- however, only the `NodeName` parameter is required.

###Defining Partitions

Partitions are defined in a similar fashion.  All of the parameters
indicated in the `slurm.conf` manpage are supported as key-value pairs:

```yaml
slurm::partitions:
    'default':
        PartitionName: 'default'
        Nodes: 
            - 'nodes[61,138-145]'
            - 'nodes[1-180]'
        Default: 'yes'
        Priority: 10000
        PreemptMode: 'off'
        MaxTime: '30-0'
        DefaultTime: '3-0'
        State: 'UP'
```

> Note that quoting is required for many of the boolean parameters (i.e. 'yes',
> 'off', etc) as the YAML interpreter will change these to "true" and "false"
> if left bare.

Many parameters are implemented as lists.

#Reference:

##Classes

- `slurm`: Installs Slurm binaries and configuration files
- `slurm::slurmdbd`: Installs the database daemon and its configuration files. Requires that MySQL be installed and running and the database installed and configured for DBD.





