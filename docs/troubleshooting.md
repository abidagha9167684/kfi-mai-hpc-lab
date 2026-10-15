# Troubleshooting record

| Incident | Root cause and fix |
|---|---|
| Slurm node `NOT_RESPONDING` | The AWS Security Group did not allow the internal Slurm traffic. A shared cluster security group fixed it |
| `srun` hung while the node was idle | UFW blocked dynamic job-step ports. Set `SrunPortRange=60001-60010` and allowed it |
| NFS missing after a restart | TCP 2049 was not allowed in UFW. Added a private-network rule and ran `mount -a` |
| `Permission denied` as root on NFS | Expected `root_squash`. Kept for security, researchers use the group |
| Job stuck in COMPLETING | The job exceeded its time limit. Controlled recovery, then a larger time limit |
| Grafana dashboard disappeared | The dashboard had never been saved to `grafana.db`. Re-imported the JSON in `monitoring/` and saved |
| n8n SSH handshake timeout | The public IP of `hpc-admin` changed after an EC2 restart. Updated the credential, Elastic IP recommended |
| n8n result reader denied | The `ubuntu` user could not traverse the protected results directory. Read it with `sudo -u researcher1` |

## Method
1. Service: `systemctl status SERVICE`
2. Logs: `journalctl -u SERVICE`
3. Reachability: `ping HOST`
4. Port: `nc -zv HOST PORT`, `ss -lntp`
5. Firewall: `ufw status numbered` and the AWS Security Group
6. Permissions: `id`, `groups`, `ls -ld`
7. Configuration, and only then a restart or change

## After an EC2 restart
Public IPs may change. NFS can fail at boot when the server is not ready yet (the `_netdev` option helps). Grafana dashboards survive only if saved or provisioned from JSON.
