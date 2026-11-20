# Vaultwarden – Backup and Recovery Plan

## 1. Objective

This document describes the implemented backup and recovery strategy for the Vaultwarden deployment.

The objective is to protect application data against accidental deletion, container failures, and deployment errors while ensuring that backups can be restored successfully.

## 2. Data Requiring Backup

Vaultwarden application data is stored in:

`/opt/vaultwarden/data`

The backup process preserves the following data:

| Data | Purpose |
|---|---|
| `db.sqlite3` | Stores the Vaultwarden database and user vault information. |
| `rsa_key.pem` | Stores RSA key material required by the application. |
| `attachments/` | Stores uploaded attachments, when present. |
| `sends/` | Stores Vault Send files, when present. |
| `config.json` | Stores application configuration, when present. |
| `icon_cache/` | Stores cached website icons, when present. |

The SQLite database is backed up using SQLite's online backup mechanism to maintain database consistency.

## 3. Backup Strategy

A Bash script, `scripts/backup-vaultwarden.sh`, automates the backup process.

The implemented strategy includes:

- Creating a consistent SQLite database backup using SQLite's `.backup` command.
- Preserving the RSA encryption key.
- Including additional application data directories and configuration files when present.
- Creating compressed, timestamped `.tar.gz` archives.
- Storing backup archives separately from the active application data.
- Restricting backup archive permissions to prevent unauthorized access.
- Removing backup archives older than 24 hours.

The script creates temporary working directories during backup and removes them after execution.

## 4. Backup Location

Backups are stored in:

`/opt/vaultwarden/backups`

Example archive:

`vaultwarden-20261120_115119.tar.gz`

The backup directory is separate from the active Vaultwarden data directory.

Backup archives are created with restrictive file permissions (`600`).

For stronger disaster recovery protection, backups should eventually be copied to encrypted off-host or cloud storage.

## 5. Automated Backup Schedule

Automated backups are configured using the Linux root user's crontab.

The current schedule is:

```cron
*/5 * * * * /bin/bash /mnt/c/Users/Admin/Desktop/vaultwarden-nomad/scripts/backup-vaultwarden.sh >> /var/log/vaultwarden-backup.log 2>&1
```

This configuration runs the backup script every five minutes and records its output in:

`/var/log/vaultwarden-backup.log`

The cron execution was verified, and new timestamped backup archives were successfully generated.

**Note:** Because this deployment runs in WSL2, scheduled backups depend on the WSL environment being active.

## 6. Backup Integrity Verification

Backup integrity was checked by:

1. Extracting a generated backup archive into a temporary directory.
2. Verifying that the database file was present.
3. Running SQLite's integrity check against the extracted database.

Command used:

```bash
sudo sqlite3 /tmp/vaultwarden-restore-check/data/db.sqlite3 "PRAGMA integrity_check;"
```

Result:

```text
ok
```

This confirmed that the backed-up SQLite database passed the integrity check.

## 7. Restoration Procedure

A separate restore-test data directory was created:

`/opt/vaultwarden/restore-test-data`

The restoration was performed without stopping or overwriting the live Vaultwarden deployment.

The procedure involved:

1. Selecting the latest available backup archive.
2. Extracting the archive into a temporary directory.
3. Copying the recovered application data into the separate restore-test directory.
4. Applying the required directory ownership and permissions.
5. Verifying the restored SQLite database.
6. Starting a temporary Vaultwarden container using the same pinned application image.
7. Configuring a separate HTTPS reverse-proxy endpoint for the restored instance.
8. Accessing the restored instance through `https://vaultwarden-restore.local`.
9. Logging in with the existing test account.
10. Confirming that the previously created test vault entry was available.

The restore test used a separate container and data directory to protect the live deployment.

## 8. Recovery Verification

The restoration test was successful.

The following checks were completed:

| Verification | Result |
|---|---|
| Backup archive created successfully | Passed |
| SQLite database integrity check | Passed |
| Restored Vaultwarden container started | Passed |
| Restored application health endpoint | HTTP 200 |
| HTTPS access to restored instance | Passed |
| Test account authentication | Passed |
| Previously created test vault entry recovered | Passed |
| Live Vaultwarden deployment remained running | Passed |

The recovered test vault entry confirmed that the backup contained usable application data.

The temporary restore-test container was removed after verification. The original Nomad-managed Vaultwarden deployment remained running.

## 9. Backup Security

Backup archives contain sensitive application information and must be protected.

The following security measures are applied:

- Backup archives are stored outside the active application data directory.
- Backup files use restrictive permissions.
- The backup directory is protected from unauthorized access.
- Sensitive backup files must never be committed to Git.
- Backup archives should be encrypted before transfer to external storage.
- Restore operations must use a separate data directory when testing recovery.
- Live application data must not be overwritten during restore testing.

## 10. Implementation Status

The backup and recovery implementation has been completed and tested.

Implemented components include:

- Automated Bash backup script.
- SQLite-consistent database backup.
- Timestamped compressed backup archives.
- Five-minute cron scheduling.
- Backup logging.
- Twenty-four-hour backup retention.
- SQLite integrity verification.
- Isolated restoration environment.
- HTTPS access to the restored application.
- Successful authentication and recovery of an existing test vault entry.

The restore test demonstrated that the backup can be used to recover Vaultwarden data successfully.

**Future improvement:** Configure encrypted off-host backup storage and consider a longer retention policy for production use.