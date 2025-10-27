---
title: "Amazon EKS"
description: "Installing Imageless Kubernetes to Amazon EKS"
---

If you have an existing EKS cluster, we recommend creating a new node group specifically for Imageless Kubernetes.

To run on EKS, each node in the node group will need to:

- Install Flox
- Install the Flox `containerd` runtime shim
- Register the shim with `containerd`
- Register the shim with Kubernetes

Most of this can be done as part of the node bootstrapping process, using custom user data to pass instructions to [nodeadm][nodeadm].

!!! note "Note"
    Additional information on `nodeadm` and bootstrapping with user data can be found in the [EKS documentation][userdata-docs].

This guide will walk through the steps needed to create the node group and configure the cluster with both [Terraform][terraform] and [eksctl][eksctl].

!!! info "Info"
    The below examples are tailored towards adding node groups to existing clusters -- complete examples for creating new clusters with Imageless Kubernetes are available on [GitHub][k8s-shim-install].

--8<-- "k8s-shim-cli-version.md"

## Node Configuration via Terraform

### Terraform Prerequisites

To create the node group, you will need:

- Subnets for the node group to use
- IDs for cluster and node security groups
- The cluster's service CIDR (i.e. the range from which cluster services will recieve IPs)

If you've used a public module such as [terraform-aws-eks][terraform-aws-eks], most of these details should be available either from the module configuration or outputs.

### Terraform node group creation

This example will use the [eks-managed-node-group][eks-managed-node-group] submodule of [terraform-aws-eks][terraform-aws-eks], but it can also be used standalone, regardless of how the cluster was defined in Terraform.

The below Terraform configuration can be used to provision a node group with the Flox runtime; see comments for guidance on each input.
The below configuration assumes you already have Terraform configuration for a cluster including the [AWS provider][aws-tf-provider].

```hcl title="nodegroup.tf"
module "eks_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "21.6.1" # tested with this version, but only >=21 required

  name         = "flox"
  cluster_name = "my-cluster"

  # replace with your node subnets
  subnet_ids = ["subnet-01982749e3b6e77a6", "subnet-025dd07e5117afef5", "subnet-0b0ef36fe25286a83"] 

  # replace with your desired instance types -- x86_64 or ARM (Graviton) are supported
  instance_types = ["t3.small"] 

  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids            = [module.eks.node_security_group_id]
  cluster_service_cidr              = module.eks.cluster_service_cidr

  ami_type     = "AL2023_x86_64_STANDARD" # set depending on CPU architecture
  desired_size = 1
  min_size     = 1
  max_size     = 10

  # required if you need non-default disk settings; disk_size parameter cannot be used with cloudinit_pre_nodeadm
  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 50
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = true
      }
    }
  }

  # needed to pair with the RuntimeClass to ensure Flox pods only get scheduled here
  labels = {
    "flox.dev/enabled" = "true"
  }

  cloudinit_pre_nodeadm = [
    {
      content_type = "text/x-shellscript; charset=\"us-ascii\""
      content      = <<-EOT
            #!/bin/bash
            dnf install -y https://flox.dev/downloads/yumrepo/flox.x86_64-linux.rpm
            flox activate -r flox/containerd-shim-flox-installer --trust -g 2
          EOT
    },
    {https://registry.terraform.io/providers/hashicorp/aws/latest/docs
      content_type = "application/node.eks.aws"
      content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              cluster: {}
              containerd:
                config: |
                  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.flox]
                    # Our shim is a build of the runc shim with hooks, so override runtime_path
                    # here but otherwise obey all the runc protocol specifications.
                    runtime_path = "/usr/local/bin/containerd-shim-flox-v2"
                    runtime_type = "io.containerd.runc.v2"
                    # Whitelist all annotations starting with "flox.dev/"
                    pod_annotations = [ "flox.dev/*" ]
                    container_annotations = [ "flox.dev/*" ]
                  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.flox.options]
                    SystemdCgroup = true
              instance:
                localStore: {}
              kubelet: {}
          EOT
    }
  ]
}
```

In the above example, the `cloudinit_pre_nodeadm` section is used by `nodeadm` to bootstrap the node as it starts up.

First, it installs Flox on the node using the latest `rpm` package, which will then be used to create pods backed by Flox environments.

Then, the `flox activate` command executes an [installer][shim-installer] that detects the node's running `containerd` version, downloads the correct version of the Flox runtime shim to match, and installs it to `/usr/local/bin` on the node.

Finally, it uses a `NodeConfig` manifest to leverage `nodeadm`'s native functionality to update the node's `containerd` configuration to be aware of the Flox runtime.

The `labels` section is used to give each Flox-enabled node an identifier to ensure that Flox pods only target these nodes.
The `label` is used in concert with a `RuntimeClass` in the next section to make Kubernetes aware of the Flox runtime.

## Node Configuration via eksctl

For clusters created using methods other than Terraform (e.g. AWS management console), we recommend using [eksctl][eksctl] to create the Flox node group.

`eksctl` is a utility made by AWS to create and manage EKS clusters, including clusters it did not create.

For our purposes, `eksctl` greatly simplifies appending custom configuration to the base launch template.

### eksctl Prerequisites

- A running EKS cluster with at least one existing node group
- List of VPC subnet IDs to be used for the new node group
- Connectivity to the cluster API (i.e. `kubectl` is usable)

### Installation

#### Cluster access

First, install `ekctl` and ensure that you have access to the cluster:

- Install `eksctl` (e.g. `flox install eksctl`).
- Set AWS credentials in your environment (e.g. copy `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from management console).
- Run `eksctl get cluster` and ensure the cluster is visible via the command below.

<!-- markdownlint-disable MD010 -->
```sh
❯ eksctl get cluster
NAME		REGION		EKSCTL CREATED
flox	    us-east-1	True
```

#### eksctl node group creation

Next, we'll create a `ClusterConfig` manifest that will be used to create the Flox node group.

!!! note "Note"
    See the [eksctl documentation][eksctl-docs] for guidance on additional parameters such as IAM configuration and autoscaler support.

Apply the below `ClusterConfig` with `eksctl create nodegroup -f nodegroup.yaml`. You can also visualize the changes before deployment with `eksctl create --dry-run`.

```yaml title="nodegroup.yaml"
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: flox # name of the target cluster for this node group
  region: us-east-1

# adjust this to match your existing or desired node group configuration -- below values are examples
managedNodeGroups:
  - name: flox
    instanceType: t3.small # choose your desired instance type
    amiFamily: AmazonLinux2023
    desiredCapacity: 1
    minSize: 0
    maxSize: 5
    labels:
      flox.dev/enabled: "true" # used in RuntimeClass to ensure flox workloads only get scheduled on these nodes
    preBootstrapCommands:
      - |
         dnf install -y https://flox.dev/downloads/yumrepo/flox.x86_64-linux.rpm
         flox activate -r flox/containerd-shim-flox-installer --trust
    overrideBootstrapCommand: |
      apiVersion: node.eks.aws/v1alpha1
      kind: NodeConfig
      spec:
        containerd:
          config: |
            [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.flox]
              # Our shim is a build of the runc shim with hooks, so override runtime_path
              # here but otherwise obey all the runc protocol specifications.
              runtime_path = "/usr/local/bin/containerd-shim-flox-v2"
              runtime_type = "io.containerd.runc.v2"
              # Whitelist all annotations starting with "flox.dev/"
              pod_annotations = [ "flox.dev/*" ]
              container_annotations = [ "flox.dev/*" ]
            [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.flox.options]
              SystemdCgroup = true
              
 # required if cluster was not created with eksctl, see https://docs.aws.amazon.com/eks/latest/eksctl/unowned-clusters.html#create-nodegroup
 vpc:
  id: "vpc-12345"
  securityGroup: "sg-12345"    # this is the ControlPlaneSecurityGroup
  subnets:
    # should match the IDs of subnets attached to existing node group
    private:
      private1:
        id: "subnet-12345"
      private2:
        id: "subnet-67890"
    public:
      public1:
        id: "subnet-12345"
      public2:
        id: "subnet-67890"
```

Further explanation of the bootstrapping process is available in the Terraform section above.

## Kubernetes Configuration

A [RuntimeClass](https://kubernetes.io/docs/concepts/containers/runtime-class/) is used to expose the runtime to Kubernetes such that it can be utilized to create pods.
The below `RuntimeClass` needs to be applied to the cluster, where the `nodeSelector` matches the `label` given to the node group above

```yaml title="RuntimeClass.yaml"
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: flox
handler: flox
scheduling:
  nodeSelector:
    flox.dev/enabled: "true"
```

which can be applied by `kubectl apply -f RuntimeClass.yaml`

The `nodeSelector` ensures that Flox pods will only be scheduled on nodes with the Flox runtime installed.

## Conclusion

Once the node group is running, you are ready to create pods using the Flox runtime.

A sample `Pod` manifest is available in the [Introduction][intro-section], but any Kubernetes resource that creates a pod (e.g. `Deployment`) can be used by setting the `runtimeClassName` parameter to `flox`.

[intro-section]: ../intro.md
[eksctl]: https://docs.aws.amazon.com/eks/latest/eksctl/
[eksctl-docs]: https://docs.aws.amazon.com/eks/latest/eksctl/nodegroup-managed.html
[terraform]: https://developer.hashicorp.com/terraform
[terraform-aws-eks]: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
[eks-managed-node-group]: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group
[userdata-docs]: https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-user-data
[nodeadm]: https://github.com/awslabs/amazon-eks-ami/blob/main/nodeadm
[shim-installer]: https://hub.flox.dev/flox/containerd-shim-flox-installer
[aws-tf-provider]: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
[k8s-shim-install]: https://github.com/flox/k8s-shim-install
