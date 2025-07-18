---
title: Catalog Store
description: Create a Catalog Store for publishing your own Flox packages
---

# Setting up a Catalog Store

Note that this page is only relevant if your organization has chosen to provide its own Catalog Store.
By default provides a pre-configured Catalog Store to each organization as part of the organization's private Catalog.

A user-provided Catalog Store is an AWS S3 bucket
or any S3 compatible service, like [MinIO][minio-s3-compatible]{:target="\_blank"}
or [Backblaze B2][backblaze-b2-cloud-storage]{:target="\_blank"}. (For the
sake of simplicity, this guide focuses on S3, but there are other providers
available if you prefer them to AWS.)

To configure your Catalog to use this Catalog Store, you will need to set ingress (where new packages are uploaded to) and egress (where packages are downloaded from) URIs for the Catalog.
This is done with a command line utility provided by Flox.

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

### Policy example

By default, S3 buckets are normally confined to be read by the bucket owner or users within the same AWS account. This is likely a decent starting point for the Catalog Store. However, if you'd like to make your published Flox software available to a wider audience, you can use the following policy as a starting point. Note this will make the contents of the bucket public, so be sure to understand the implications of this before applying it.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
    }
  ]
}
```

## Ensure the Nix Daemon has access to the S3 Bucket

As you probably know by now, the underlying technology powering Flox is Nix.
Accordingly, we need to take a couple steps to ensure that the Nix daemon
has access to the S3 bucket you've just created.
To do so, we need to get AWS credentials, specifically `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and, if applicable, `AWS_SESSION_TOKEN`.
Use the `aws configure` or `aws configure sso` command [as described in the CLI reference][aws-cli-configure-command]{:target="\_blank"} to set those same values, and ensure that the AWS profile and region match those configured for the S3 bucket.

You can confirm that everything is set up correctly by inspecting the values stored in `$HOME/.aws/credentials`.

[aws-cli-configure-command]: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/index.html#configure

## Set Catalog Store ingress and egress URIs

Reach out to your Flox point of contact to accomplish this step.

## Create and set a signing key

At this point, you should have an appropriately configured Catalog Store
to which you can publish your own software via the `flox publish` command.
In order for users to upload artifacts to the Catalog Store and then install those artifacts, you must configure public and private signing keys.

The private key is used to sign artifacts before uploading them, whereas the public key must be distributed to anyone you wish to be able to install those published artifacts.
See the [signing keys][signing-keys] Cookbook page for instructions on configuring your signing keys.

[signing-keys]: ./signing-keys.md
