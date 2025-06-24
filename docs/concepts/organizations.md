# Understanding Organizations in FloxHub

--8<-- "paid-feature.md"

An **organization** in FloxHub represents a shared workspace for teams. It provides:

- A private catalog
- Scoped access control
- A foundation for collaboration among multiple users

This document outlines how organizations work today, and how they can be managed.

## User Membership

A user can belong to more than one organization. This allows users to use a single FloxHub account in multiple contexts.

## Permissions and Access Control

Organizations in FloxHub use role-based access control (RBAC) to assign permissions to organization members. A user can have one of the following roles within an organization:

- **Owner**: Full administrative access, including managing members and settings.
- **Writer**: Can create and update environments and packages, but cannot manage members or organization settings.
- **Reader**: Can view and pull environments and can install packages, but cannot create or modify them.

The organization must have at least one owner, but may have multiple. Owners can manage the organization, including adding or removing members and changing roles. Owners may not modify their own role or remove themselves from the organization.

## Machine Access Tokens

In addition to _user-level_ access based on FloxHub accounts, FloxHub supports _programmatic_ access via `Auth0`-issued machine tokens, using the client credentials grant. These tokens are not tied to users—they authenticate as the organization itself and are intended for CI/CD or other non-interactive use cases.

FloxHub supports this via the client credentials grant. To enable it, contact the Flox team to request a client ID and secret. Once provisioned, your workflows can fetch an access token using a `curl` command:

```
curl --request POST \
  --url https://auth.flox.dev/oauth/token \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data "client_id=YOUR_CLIENT_ID" \
  --data "client_secret=YOUR_CLIENT_SECRET" \
  --data "audience=https://hub.flox.dev/api" \
  --data "grant_type=client_credentials"
```

The token can be used to authenticate calls to FloxHub’s API or CLI tools in the context of your organization.

## Environment Visibility and Management

Organizations in FloxHub include a view of all environments and packages owned by the organization.

For each environment, users can:

- See the current generation and a history of changes
- Configure basic settings, such as owner and name
- Delete environments

For each package, users can:

- See package details, including supported systems and available versions

Environments and packages created within an organization are visible to all its members, with access governed by the organization’s RBAC configuration.
