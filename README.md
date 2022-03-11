# Slurm Docker Cluster

This is a multi-container Slurm cluster using docker-compose.  The compose file
creates named volumes for persistent storage of MySQL data files as well as
Slurm state and log directories.

This is a fork of <https://github.com/giovtorres/slurm-docker-cluster,> including the latest
slurm as default, basic BATS <https://github.com/bats-core/bats-core,> testing which
determines whether the correct version of Slurm is installed, two nodes are available,
and a job can be submitted.

## Testing

Typically,

```make test```

On OS X, you must install a newer version of GNU Make by running:

```brew install remake```

Then run ```remake test```

## Containers and Volumes

The compose file will run the following containers:

* slurm_mysql
* slurm_slurmdbd
* slurm_slurmctld
* slurm_c1 (slurmd)
* slurm_c2 (slurmd)

The compose file will create the following named volumes:

* etc_munge         ( -> /etc/munge     )
* etc_slurm         ( -> /etc/slurm     )
* slurm_jobdir      ( -> /data          )
* var_lib_mysql     ( -> /var/lib/mysql )
* var_log_slurm     ( -> /var/log/slurm )

## Building the Docker Image

Build the image locally. The version of Slurm is selected using Docker build args and the Slurm Git
tag. Slurm tags available on https://github.com/SchedMD/slurm/tags.

```console
make build -s SLURM_TAG="slurm-20-11-4-1"
```

## Starting the Cluster

Run `docker-compose` to instantiate the cluster. ```SLURM_TAG``` is required.
Latest supported SLURM_TAG is ```slurm-21-08-6-1```.

```console
env SLURM_TAG=slurm-21-08-6-1 docker-compose up -d
```

## Accessing the Cluster

Use `docker exec` to run a bash shell on the controller container:

```console
docker exec -it slurm_slurmctld bash
```

From the shell, execute slurm commands, for example:

```console
[root@slurm_slurmctld /]# sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
normal*      up 5-00:00:00      2   idle c[1-2]
```

## Submitting Jobs

The `slurm_jobdir` named volume is mounted on each Slurm container as `/data`.
Therefore, in order to see job output files while on the controller, change to
the `/data` directory when on the **slurm_slurmctld** container and then submit a job:

```console
[root@slurm_slurmctld /]# cd /data/
[root@slurm_slurmctld data]# sbatch --wrap="uptime"
Submitted batch job 2
[root@slurm_slurmctld data]# ls
slurm-2.out
```

## Stopping and Restarting the Cluster

```console
docker-compose stop
docker-compose start
```

## Deleting the Cluster

To remove all containers and volumes, run:

```console
docker-compose down -v
```

If you want to keep your configuration and metadata as docker volumes,
just omit ```-v``` and run

```console
docker-compose down
```
