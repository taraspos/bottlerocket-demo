# Bottlerocket EKS demo

## Prerequisites

- AWS Account
- [eksctl](https://eksctl.io/)
- (optional) [Teleport](https://goteleport.com/)
    - Teleport cluster - you can get free 14 days trial here - https://goteleport.com/signup/
    - Helm

>[!WARNING]
> Deploying AWS resources will result in charges as neither AWS EKS nor NAT Gateway has a free tier available.

## Deployment steps

### Preparation

- Login to AWS Console and create cloud shell
- Clone this repo in cloud shell
- [Install eksctl](https://eksctl.io/installation/)
- Prepare EKS cluster and other infrastructure with

    ```shell
    eksctl create cluster -f eksctl.yaml --without-nodegroup
    ```

- Create new in-vpc Cloud Shell
    - Select VPC created by eksctl
    - Select Private subnet created by eksctl
    - Select `ClusterSharedNodeSecurityGroup` created by eksctl

- [Install eksctl](https://eksctl.io/installation/) again :D 
- Clone this repo again

### Launching nodes

- (optional) Teleport configuration
    1. Uncomment `teleport` section in `eksctl.yaml`
    2. Set `proxy_server` value to your teleport endpoint in `teleport.yaml`
    3. Base64 encode content of `teleport.yaml` and paste it as `user-data` in `eksctl.yaml`
    4. Create IAM Join Token using Teleport Web UI

        ```yaml
        kind: token
        metadata:
          name: iam-node-join-token
        spec:
          allow:
          - aws_account: "<your_account_id>"
            aws_arn: arn:aws:sts::<your_account_id>:assumed-role/eksctl-bottlerocket-demo*-nodegroup-NodeInstanceRole-*/*
          join_method: iam
          roles:
          - Node
        version: v2
        ```

>[!NOTE]
> Due to limited configuration options available for [bottlerocket host containers](https://bottlerocket.dev/en/os/1.20.x/api/settings/host-containers),
> we need to build custom image, based of [bottlerocket-os/bottlerocket-control-container](https://github.com/bottlerocket-os/bottlerocket-control-container)
>
> Image available in this repo intended for demo purposes only.

- Run eksctl to create managed node groups

    ```shell
    eksctl create nodegroup -f eksctl.yaml 
    ```

- Configure kubectl

    ```shell
    eksctl utils write-kubeconfig -f eksctl.yaml
    ```

### (optional) Registering EKS cluster as teleport resource

- [Install helm](https://helm.sh/docs/intro/install/)

    - Go to teleport UI and select enroll EKS resource, follow the instructions

    - TODO, get proper role configs

    - Done, you should be able to access private kubernetes cluster with Teleport now

>[!WARNING]
> Roles provided here used for demo purposes only, in real world scenarios you should provide permissions according to the [Principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege)