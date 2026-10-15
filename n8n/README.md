# n8n workflow exports

Importable workflow files (n8n: *Workflows → Import from file*). They contain no credentials; after importing, attach your own SSH credential for the `hpc-admin` host to every SSH node.

| File | Workflow |
|---|---|
| [`HPC_Autopilot_n8n.json`](HPC_Autopilot_n8n.json) | Manual and 5-minute trigger, collect health, analyze, conditional auto-heal, verify, final report, audit log |
| [`HPC_Research_Job_Portal_n8n.json`](HPC_Research_Job_Portal_n8n.json) | Form, input validation against fixed allow-lists, `sbatch --parsable`, job ID parsing, status check, completion page |

These exports are an earlier, simpler version of the workflows. The extended versions described in [../docs](../docs) add an IF branch for the repair path, a status dashboard page, and a step that reads the result file with `sudo -u researcher1` and shows it in the portal.

Design points visible in the files: the portal never runs free-text commands (job type, CPUs, time limit and partition are mapped from fixed lists, and the job name is checked against `^[A-Za-z0-9._-]{1,50}$`), and the Autopilot restarts only a fixed set of services.
