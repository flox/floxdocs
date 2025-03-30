---
title: Catalog Store
description: Create a Catalog Store for publishing your own Flox packages
---

# Setting up a Catalog Store

Publishing your own software to your organization's Flox Catalog requires some
initial setup, but the process is relatively straightforward. Flox supports
publishing packages to a Catalog Store, which can exist in an AWS S3 bucket
or in any S3 compatible service, like [MinIO][minio-s3-compatible]{:target="\_blank"}
or [Backblaze B2][backblaze-b2-cloud-storage]{:target="\_blank"}. (For the
sake of simplicity, this guide focuses on S3, but there are other providers
available if you prefer them to AWS.)

In order to use an S3 bucket to store artifacts built with Flox, you will need
to set ingress and egress URIs on the catalog using a utility published by Flox.
Then, all you need to do to publish your software is to call `flox publish`,
and Flox will take care of the rest.

[minio-s3-compatible]: https://min.io/product/s3-compatibility
[backblaze-b2-cloud-storage]: https://www.backblaze.com/cloud-storage

## Configure an AWS S3 bucket

The first step in setting up your Catalog Store is creation and configuration of
an AWS S3 Bucket. There are numerous ways to accomplish this, including the AWS
Console, the AWS CLI, and Terraform (or another infrastructure-as-code tool),
to name a few. These processes are well documented, but to get started,
it's best to refer directly to AWS documentation.

- [What is Amazon S3?][amazon-s3]{:target="\_blank"}
- [AWS S3 CLI Reference][aws-cli-reference-s3]{:target="\_blank"}
- [Amazon Simple Storage Service API Reference][aws-s3-api-reference]{:target="\_blank"}

Once your S3 bucket is set up and configured with the access policies deemed
necessary by your organization's internal policies, you're ready to proceed to
the next step. Someone from Flox can help you if you run into trouble during
the setup process. Simply reach out to your designated point of contact,
and we'll work with you to get you up and running.

[amazon-s3]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html
[aws-cli-reference-s3]: https://docs.aws.amazon.com/cli/latest/reference/s3/
[aws-s3-api-reference]: https://docs.aws.amazon.com/AmazonS3/latest/API/Welcome.html

## Ensure the Nix Daemon has access to the S3 Bucket

As you probably know by now, the underlying technology powering Flox is Nix.
Accordingly, we need to take a couple steps to ensure that the Nix daemon
has access to the S3 bucket you've just created. To do so,
you have a couple of options:

1. Set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and, if applicable,
`AWS_SESSION_TOKEN` as environment variables, both for Flox and for
the daemon itself
1. Use the `aws configure` command
[as described in the CLI reference][aws-cli-configure-command]{:target="\_blank"}
to set those same values, and ensure that the AWS profile and region match those
configured for the S3 bucket

If you follow the second set of steps, you can confirm that everything is set
up correctly by inspecting the values stored in `$HOME/.aws/credentials`.

[aws-cli-configure-command]: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/index.html#configure

## Set Catalog Store ingress and egress URIs

Once you have your S3 bucket configured, the next step is to set an ingress URI
and egress URI for your Catalog Store. Flox provides a utility for you
that does exactly what you need, within a Flox environment. To use this,
you'll need to run the following command:

```sh
$ flox activate -r flox/flox-catalog-util
```

When you run this command, you'll see the following output:

```console
✅ You are now using the environment 'flox/flox-catalog-util (remote)'.
To stop using this environment, type 'exit'
```

Within the active Flox environment, you can simply run the following command:

```sh
$ catalog-util store --catalog "<my-catalog-name>" set nixcopy \
    --ingress-uri "s3://<my-bucket>" \
    --egress-uri "s3://<my-bucket>"
```

You'll note that it's possible to set the ingress and egress URIs to the same
value, if you wish to do so.

## Create and set a signing key

At this point, you should have an appropriately configured Catalog Store
to which you can publish your own software via the `flox publish` command.
In order for users to upload artifacts to the Catalog Store and then install those artifacts, you must configure public and private signing keys.

The private key is used to sign artifacts before uploading them, whereas the public key must be distributed to anyone you wish to be able to install those published artifacts.
See the [signing keys][signing-keys] Cookbook page for instructions on configuring your signing keys.

[signing-keys]: ./signing-keys.md
