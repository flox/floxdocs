# Understanding Organizations in FloxHub

--8<-- "paid-feature.md"

An **organization** in FloxHub represents a shared workspace for teams. It provides:

- A private catalog
- Scoped access control
- A foundation for collaboration among multiple users

This document outlines how organizations work today, and how they can be managed.

## Creating an Organization

At this time, creating an organization for FloxHub  is a manual process. To request a new organization, contact the Flox team directly via your preferred communication channel.

When making a request, be prepared to provide:

- The name of your organization
- A list of GitHub usernames to be associated with the org
- Whether each user should have read or write access to the organization's catalog

Currently, each organization can support a single private catalog.

## User Membership

A user can belong to more than one organization. This way users can collaborate across different teams or business units while maintaining clear separation between environments, catalogs, and permissions.

## Managing Organization Properties

The properties of an organization (such as membership or access levels) can be updated upon request. Updates _must* be initiated by the organization’s owner. Please contact the Flox team with the desired changes and we will handle the update process.

## Permissions and Access Control

- Each organization has an owner
- Each organization is associated with a single private catalog
- Access to the catalog is granted based on each user’s GitHub username
- Read and write privileges can be assigned on a per-user basis

## Machine Access Tokens

In addition to _user-level_ access based on GitHub usernames, FloxHub supports _programmatic_ access via `Auth0`-issued machine tokens, using the client credentials grant. These tokens are not tied to users—they authenticate as the organization itself and are intended for CI/CD or other non-interactive use cases.

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

Organizations in FloxHub include a view of all environments owned by the organization.

For each environment, users can:

- See the current generation and a history of changes
- Configure basic settings, such as owner and name
- Delete environments

Environments created within an organization are visible to all its members, with access governed by the organization’s catalog permissions.

## Limitations and Future Work

We’re working to enable each owner to self-manage the organization they create. Unfortunately, in the near term, all changes to a FloxHub organization must be handled manually by the Flox team.

For any questions or requests related to your organization, please reach out to your Flox representative.

[early]: https://flox.dev/early/
