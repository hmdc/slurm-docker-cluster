#!/usr/bin/env bats
load './test_helper/bats-support/load'
load './test_helper/bats-assert/load'

DIR="$(dirname $BATS_TEST_FILENAME)"
SLURM_VERSION="$(echo -n ${SLURM_TAG}|awk -F- '{print $2"."$3"."$4}')"

@test 'check slurm version matches SLURM_TAG' {
    run docker exec slurm_slurmctld slurmctld -V
    assert_output --regexp "^slurm ${SLURM_VERSION}$"
}

@test 'two nodes are available' {
    timeout 5m bash <<EOF
	until docker exec slurm_slurmctld sinfo -o '%D' --noheader &>/dev/null; do
		sleep 5s;
	done
EOF
    
    run docker exec slurm_slurmctld sinfo -o '%D' --noheader
    assert_output --regexp "^2$"
}

@test 'job can be submitted' {
    run docker exec slurm_slurmctld bash -c "cd /data; sbatch --wrap='echo L' -o out.log"
    
    timeout 5m bash <<EOF
        until docker exec slurm_slurmctld test -f /data/out.log; do
		sleep 5s;
    	done
EOF

    run docker exec slurm_slurmctld cat /data/out.log
    assert_output --regexp "^L$"
}
