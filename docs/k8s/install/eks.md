---
title: "Amazon EKS"
description: "Installing Kubernetes on Flox to Amazon EKS"
---

# EKS via eksctl

This page describes how to add a node group configured with Imageless Kubernetes to an existing EKS cluster using [eksctl][eksctl].
`eksctl` is a utility made by AWS to create and manage EKS clusters.
For our purposes, `eksctl` greatly simplifies appending custom configuration to the base launch template.

## Prerequisites

- A running EKS cluster with at least one existing node group
  - Created with any mechanism; `eksctl` can modify clusters that it did not create
- List of VPC subnet IDs to be used for the new node group
- Connectivity to the cluster API (i.e. `kubectl` is usable)

## Installation

### Cluster access

First install `ekctl` and ensure that you have access to the cluster.

- Install `eksctl` (e.g. `flox install eksctl`).
- Set AWS credentials in your environment (e.g. copy `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from management console).
- Run `eksctl get cluster` and ensure the cluster is visible via the command below.

<!-- markdownlint-disable MD010 -->
```sh
❯ eksctl get cluster
NAME		REGION		EKSCTL CREATED
flox-sandbox	us-east-1	True
```

### ClusterConfig

Create a `ClusterConfig` manifest that will be used to create the Flox node group
See the [eksctl documentation][eksctl-docs] for guidance on additional parameters such as IAM configuration.
`eksctl` ultimately synthesizes a CloudFormation stack to create the node group.

Apply the `ClusterConfig` with `eksctl create nodegroup -f nodegroup.yaml`, where `nodegroup.yaml` is the file below. You can also visualize the changes before deployment with `eksctl create --dry-run`.

```yaml title="nodegroup.yaml"
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: flox-sandbox # name of the target cluster for this node group
  region: us-east-1

# adjust this to match your existing or desired node group configuration -- below values are examples
managedNodeGroups:
  - name: flox
    instanceType: t3.small # choose your desired instance type
    amiFamily: AmazonLinux2023
    desiredCapacity: 1
    minSize: 0 # set node group size constraints
    maxSize: 5
    labels:
      # any node labels
      flox.dev/enabled: "true" # used in RuntimeClass to ensure flox workloads only get scheduled on these nodes
    tags:
      # any node tags, e.g.
      # k8s.io/cluster-autoscaler/enabled: "true"
      # k8s.io/cluster-autoscaler/flox-sandbox: "owned"
    preBootstrapCommands:
      - |
         dnf install -y https://flox.dev/downloads/yumrepo/flox.x86_64-linux.rpm
         flox activate -r flox-public/containerd-shim-flox-installer --trust
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

### Runtime

Apply the `RuntimeClass` that will allow pods to be scheduled using Imageless Kubernetes via `kubectl -f apply runtimeclass.yaml` where `runtimeclass.yaml` is the file shown below:

```yaml title="runtimeclass.yaml"
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: flox
handler: flox
scheduling:
  nodeSelector:
    flox.dev/enabled: "true"
```

### Deployment

Once nodes and the `RuntimeClass` are created, use the `runtimeClassName` field to set a pod to use the Flox runtime, and the `flox.dev/environment` annotation to define which FloxHub environment to instantiate in the pod.
Create this deployment via `kubectl apply -f deployment.yaml` where `deployment.yaml` is the file below

Example:

```yaml title="deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flox-containerd-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flox-containerd-demo
  template:
    metadata:
      labels:
        app: flox-containerd-demo
      annotations:
        flox.dev/environment: "limeytexan/echoip" # sets environment from FloxHub to use
    spec:
      runtimeClassName: flox # required to use Flox runtime
      dnsPolicy: Default    # inherit the node's /etc/resolv.conf
      containers:
        # The following container is not used but is required by the
        # Kubernetes pod specification. Any valid values can be used here.
        - name: empty
          image: flox/empty:1.0.0
          # The following command is the command that is invoked by `flox activate`
          # to keep the environment alive. It can be used to perform supplementary
          # actions at startup, and when this command exits the pod is torn down.
          command: ["echoip"]
          volumeMounts:
            - name: cache-volume
              mountPath: /cache
      volumes:
        - name: cache-volume
          emptyDir: {}
```

## Conclusion

You should now have Imageless Kubernetes configured on your cluster so that you can run pods on top of Flox environments.

[eksctl]: https://docs.aws.amazon.com/eks/latest/eksctl/
[eksctl-docs]: https://docs.aws.amazon.com/eks/latest/eksctl/nodegroup-managed.html
