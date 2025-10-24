---
title: "Amazon EKS"
description: "Installing Imageless Kubernetes to Amazon EKS using Terraform"
---

# EKS Installation with Terraform
If you have an existing EKS cluster created with Terraform, we recommend creating a new node group specifically for Imageless Kubernetes.

To run on EKS, each node in the node group will need to:

- Install Flox
- Install the Flox `containerd` runtime shim
- Register the shim with `containerd`
- Register the shim with Kubernetes

Most of which can be done as part of the node bootstrapping process, using custom user data to pass instructions to [nodeadm](https://github.com/awslabs/amazon-eks-ami/blob/main/nodeadm). 

!!! note "Note"
    Additional information on `nodeadm` and bootstrapping with user data can be found in the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-user-data).

This guide will walk through the steps needed to create the node group and configure the cluster.

## Prerequisites
To create the node group, you will need need:

- Subnets for the node group to use
- IDs for cluster and node security groups
- The cluster's service CIDR (i.e. the range from which cluster services will recieve IPs)

If you've used a public module such as [terraform-aws-eks](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest), most should be available either from the module configuration or outputs.

## Terraform Configuration
This example will use the [eks-managed-node-group](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group) submodule of `terraform-aws-eks`, but it can also be used standalone regardless of how the cluster was defined in Terraform.

The below Terraform configuration can be used to provisition a node group with the Flox runtime; see comments for guidance on each input.
```hcl title="nodegroup.tf"
module "eks_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "21.6.1" # tested with this version, but only >=21 required

  name         = "flox"
  cluster_name = "my-cluster"

  subnet_ids = ["subnet-01982749e3b6e77a6", "subnet-025dd07e5117afef5", "subnet-0b0ef36fe25286a83"] # replace with your node subnets

  instance_types = ["t3.small"] # replace with your desired instance types -- x86_64 or ARM (Graviton) are supported

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
    {
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

Then, the `flox activate` command executes an [installer](https://hub.flox.dev/flox/containerd-shim-flox-installer) that detects the node's running `containerd` version, downloads the correct version of the Flox runtime shim to match, and installs it to `/usr/local/bin` on the node. 

Finally, it uses a `NodeConfig` manifest to leverage `nodeadm`'s native functionality to update the node's `containerd` configuration to be aware of the Flox runtime.

The `labels` section is used to give each Flox-enabled node an identifier to ensure that Flox pods only target these nodes. The `label` is used in concert with a `RuntimeClass` in the next section to make Kubernetes aware of the Flox runtime.

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

## Conclusion
Once the node group is running, you are ready to create pods using the Flox runtime. 
A sample `Pod` manifest is available in the [Introduction][intro-section], but any Kubernetes resource that creates a pod (e.g. `Deployment`) can be used by setting the `runtimeClassName` parameter to `flox`.

[intro-section]: ../../intro.md
