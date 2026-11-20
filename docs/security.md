# Vaultwarden – Security Configuration

## 1. Security Objective

The objective is to protect the Vaultwarden deployment, its stored data, administrative functionality, and communication between clients and the service.

This deployment is strictly for testing and demonstration. Only dummy credentials and test accounts will be used until mentor approval is obtained.

## 2. Administrator Token Protection

Vaultwarden provides an administrative interface at `/admin`.

The administrator token protects access to this interface.

Security requirements:

- Generate a strong, randomly generated administrator token.
- Store the token outside the Git repository.
- Never hardcode the token in the Nomad job specification.
- Inject the token into the container through a secure environment variable or supported secret-management mechanism.
- Restrict access to the administration interface.
- Disable the administration interface entirely if it is not required.

## 3. User Registration

Public registration will only be enabled temporarily when creating the test account.

After account creation:

- Disable public registration.
- Verify that new public account registration is rejected.
- Keep only the required test account for demonstration.

The registration configuration must be verified against the deployed Vaultwarden version.

## 4. HTTPS and Network Security

All client access must pass through an HTTPS-enabled reverse proxy.

Security requirements:

- Use Nginx as the reverse proxy.
- Obtain and configure a valid TLS certificate for the service hostname.
- Redirect HTTP requests to HTTPS.
- Restrict direct access to the Vaultwarden application port.
- Expose only the required reverse-proxy endpoint to clients.
- Avoid exposing administrative endpoints publicly.

The application must not be considered production-ready until HTTPS access and network restrictions have been verified.

## 5. Persistent Data Protection

Vaultwarden application data will be stored in:

`/opt/vaultwarden/data`

Security requirements:

- Restrict access to the data directory.
- Avoid storing application data in the Git repository.
- Protect database files and attachments from unauthorized access.
- Ensure backup files receive appropriate filesystem permissions.
- Verify that the application container can access the required directory without granting unnecessary host permissions.

## 6. Git and Secret Management

The following items must never be committed to Git:

- Administrator tokens.
- Environment files containing secrets.
- SQLite database files.
- User vault data.
- Attachments and file uploads.
- Backup archives.
- Private keys and sensitive configuration files.

The `.gitignore` file will be used to prevent accidental inclusion of sensitive files.

Secrets will be stored outside the repository and injected into the Nomad workload through a secure mechanism.

## 7. Security Verification Checklist

The following controls must be verified before the deployment is considered complete:

- [ ] Administrator token is generated and protected.
- [ ] Administrator token is not present in the Nomad job file.
- [ ] Administrator token is not committed to Git.
- [ ] Public registration is disabled after test account creation.
- [ ] Administrative access is disabled or restricted.
- [ ] Client access works through HTTPS.
- [ ] Direct application access is restricted.
- [ ] Persistent storage permissions are appropriate.
- [ ] Backup files are protected.
- [ ] Only test accounts and dummy credentials are used.

## 8. Security Status

The controls described in this document represent the intended security configuration. Each control will be verified during deployment and testing before being marked as implemented.