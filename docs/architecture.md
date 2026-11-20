# Vaultwarden – System Architecture

## 1. Overview

Vaultwarden is a lightweight, self-hosted password management server compatible with Bitwarden clients. It will be deployed as a containerized workload on HashiCorp Nomad, with Consul providing service discovery.

This deployment is intended for an internal test environment. Only test accounts and dummy credentials will be used until the deployment has been reviewed and approved by the mentor.

## 2. Architecture Components

| Component | Responsibility |
|---|---|
| Vaultwarden | Provides the Bitwarden-compatible password management service. |
| Nomad | Schedules, deploys, and manages the Vaultwarden container. |
| Consul | Provides service discovery within the environment. |
| Docker | Runs the Vaultwarden container. |
| SQLite | Stores application data, including user and vault information. |
| Persistent Host Storage | Retains application data outside the container lifecycle. |
| Nginx Reverse Proxy | Provides the HTTPS entry point and forwards requests to Vaultwarden. |
| Backup Process | Creates scheduled backups and supports restoration. |

## 3. Application Architecture

The planned request flow is:

1. A user accesses the Vaultwarden service using a Bitwarden-compatible client or web vault.
2. The client connects to the service through an HTTPS-enabled Nginx reverse proxy.
3. Nginx forwards requests to the Vaultwarden service running inside the Nomad environment.
4. Nomad manages the Vaultwarden container through the Docker driver.
5. Vaultwarden reads and writes application data to its persistent storage directory.
6. Consul provides service discovery where required.

## 4. Data Storage

SQLite will be used as the initial database because this is a standalone deployment with a relatively small test workload. It avoids the operational overhead of deploying a separate database server.

The host directory will be:

`/opt/vaultwarden/data`

This directory will be mounted into the Vaultwarden container at:

`/data`

It will hold the SQLite database and other application data, including attachments and configuration files where applicable.

Persistent host storage ensures that application data is not tied to the lifecycle of an individual container.

## 5. Security Considerations

The deployment will follow these security practices:

- HTTPS will be required for client access through the reverse proxy.
- The Vaultwarden service will not be intentionally exposed directly to the public internet.
- Test accounts and dummy credentials will be used during implementation.
- Public registration will be disabled after creating the required test account.
- The administration interface will be disabled or restricted.
- The administrator token will be stored securely outside the Nomad job file and Git repository.
- Sensitive application data and backup files will not be committed to Git.
- Access to persistent storage will be restricted through appropriate filesystem permissions.
- Only the minimum required network access will be allowed.

## 6. Backup and Recovery

The Vaultwarden data directory will be backed up on a scheduled basis.

Backups will include the SQLite database and associated application data required for recovery.

The implementation will include:

- Automated scheduled backups.
- Protection of backup files.
- A documented restoration procedure.
- Restoration into a fresh Vaultwarden instance.
- Verification that previously created test entries are available after restoration.

## 7. Deployment Environment

The deployment will use the existing local Nomad and Consul development environment.

| Setting | Value |
|---|---|
| Orchestrator | HashiCorp Nomad |
| Service Discovery | HashiCorp Consul |
| Container Runtime | Docker |
| Database | SQLite |
| Persistent Storage | `/opt/vaultwarden/data` |
| Reverse Proxy | Nginx |
| Environment | Local development/test lab |

## 8. Deployment Objective

The objective is to demonstrate a secure, persistent, and recoverable Vaultwarden deployment managed by Nomad.

The completed deployment must demonstrate successful client access over HTTPS, persistence across restarts, restricted administrative access, scheduled backups, and successful restoration of test data.