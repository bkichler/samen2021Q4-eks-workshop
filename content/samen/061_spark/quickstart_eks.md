---
title: "Installing Apache Spark on EKS"
date: 2021-11-06T08:30:11-07:00
weight: 10
tags:
  - samen
---

## Quickstart: BKPR on Amazon Elastic Container Service for Kubernetes (Amazon EKS)

## Table of contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Installation and setup](#installation-and-setup)
- [Next steps](#next-steps)
- [Upgrading BKPR](#upgrading-bkpr)
- [Teardown and cleanup](#teardown-and-cleanup)
- [Useful links](#useful-links)

## Introduction

This document walks you through setting up an Amazon Elastic Container Service for Kubernetes (Amazon EKS) cluster and installing the Bitnami Kubernetes Production Runtime (BKPR) on it.

## Prerequisites

* [Amazon AWS account](https://aws.amazon.com/)
* [Amazon CLI](https://aws.amazon.com/cli/)
* [Amazon EKS CLI](https://eksctl.io/)
* [Kubernetes CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [AWS IAM Authenticator for Kubernetes](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
* [BKPR installer](install.md)
* [`kubecfg`](https://github.com/ksonnet/kubecfg/releases)
* [`jq`](https://stedolan.github.io/jq/)

### DNS requirements

In addition to the requirements listed above, a domain name is also required for setting up Ingress endpoints to services running in the cluster. The specified domain name can be a top-level domain (TLD) or a subdomain. In either case, you have to manually [set up the NS records](#step-3-configure-domain-registration-records) for the specified TLD or subdomain so as to delegate DNS resolution queries to an Amazon Route 53 hosted zone created and managed by BKPR.  This is required in order to generate valid TLS certificates.

## Installation and setup

### Step 1: Configure a User Pool in AWS Cognito

In order to authenticate users for applications running atop EKS, BKPR requires a User Pool in AWS Cognito to be configured.

If you already have a working User Pool in AWS Cognito that you would like to use for authenticating users, you will need to retrieve its ID in the form `${AWS_REGION}-${USER_POOL_ID}`, and export it as shown below, then skip to the [Create user](#create-a-user) section.


  ```bash
  export AWS_COGNITO_USER_POOL_ID=eu-central-1_sHSdWT6VL
  ```

If you are new to using BKPR on EKS, or if you want to create a new User Pool in AWS Cognito, follow these steps:

1. Browse to the [Cognito](https://console.aws.amazon.com/cognito/) module in the AWS Console.
2. Navigate to **Manage User Pools > Create a user pool** page.
3. Enter a valid **Pool name**, like `eks-test`, then click on the **Review defaults** button:

<p align="center"><img src="eks/1-new-user-pool.png" width=840/></p>

4. Go to the **Policies** and select the **Only allow administrators to create users** option, otherwise anyone would be able to sign up and gain access to services running in the cluster. **Save changes** before continuing to the next step:

<p align="center"><img src="eks/2-policies.png" width=840/></p>

5. Feel free to customize other sections, like **Tags**, to your liking. Once done, go to the **Review** section and click on the **Create pool** button:

<p align="center"><img src="eks/3-review.png" width=840/></p>

6. Go to **App integration > Domain name** setting and configure the Amazon Cognito domain, which has to be unique to all users in an AWS Region. Once done, click the **Save changes** button:

<p align="center"><img src="eks/4-domain.png" width=840/></p>

7. Select the **General settings** option, note the **Pool Id** and export its value:

  ```bash
  export AWS_COGNITO_USER_POOL_ID=eu-central-1_sHSdWT6VL
  ```

#### Create a user

In order to access protected resources which require authentication, such as Prometheus, Kibana or Grafana, you will need to create users in the newly-created user pool. The next steps highlight how to create a test user which can be used to access these protected resources:

1. Browse to the [Cognito](https://console.aws.amazon.com/cognito/) module in the AWS Console.
1. Navigate to the **Manage User Pools > YOUR_USER_POOL > Users and Groups > Create user** page.
1. Fill in the input fields as shown below:

<p align="center"><img src="eks/4-new-user.png" width="400"></p>

At any time, if you are presented with an Amazon AWS authentication form, you can use this user account to authenticate against protected resources in BKPR.

NOTE: if the credentials you configured for the user fail to work, e.g.
getting into a "loop" being asked for password change after 1st login, while
consistently not succeeding, you may need to forcebly set its credentials and
state with:

  ```bash
  aws --region REGION cognito-idp admin-set-user-password --user-pool-id ID --username USER --password PASS --permanent
  ```


### Step 2: Deploy BKPR

To bootstrap your Kubernetes cluster with BKPR, use the command below:

  ```bash
  kubeprod install eks \
    --email ${AWS_EKS_USER} \
    --dns-zone "${BKPR_DNS_ZONE}" \
    --user-pool-id "${AWS_COGNITO_USER_POOL_ID}"
  ```

Wait for all the pods in the cluster to enter the `Running` state:

  ```bash
  kubectl get pods -n kubeprod
  ```

### Step 3: Configure domain registration records

BKPR creates and manages a DNS zone which is used to map external access to applications and services in the cluster. However, for it to be usable, you need to configure the NS records for the zone.

Query the name servers of the zone with the following command and configure the records with your domain registrar.

  ```bash
  BKPR_DNS_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "${BKPR_DNS_ZONE}" \
                                                           --max-items 1 \
                                                           --query 'HostedZones[0].Id' \
                                                           --output text)
  aws route53 get-hosted-zone --id ${BKPR_DNS_ZONE_ID} --query DelegationSet.NameServers
  ```

Please note that it can take a while for the DNS changes to propagate.

### Step 4: Access logging and monitoring dashboards

After the DNS changes have propagated, you should be able to access the Prometheus, Kibana and Grafana dashboards by visiting `https://prometheus.${BKPR_DNS_ZONE}`, `https://kibana.${BKPR_DNS_ZONE}` and `https://grafana.${BKPR_DNS_ZONE}` respectively. Login with credentials created in the [Create a user](#create-a-user) step.

Congratulations! You can now deploy your applications on the Kubernetes cluster and BKPR will help you manage and monitor them effortlessly.

## Next steps

- [Installing Kubeapps on BKPR](kubeapps-on-bkpr.md)

## Upgrading BKPR

### Step 1: Update the installer

Follow the [installation guide](install.md) to update the BKPR installer binary to the latest release.

### Step 2: Edit `kubeprod-manifest.jsonnet`

Edit the `kubeprod-manifest.jsonnet` file that was generated by `kubeprod install` and update the version referred to in the `import` statement. For example, the following snippet illustrates the changes required in the `kubeprod-manifest.jsonnet` file if you're upgrading to version `v1.3.0` from version `v1.2.0`.

```diff
 // Cluster-specific configuration
-(import "https://releases.kubeprod.io/files/v1.2.0/manifests/platforms/eks.jsonnet") {
+(import "https://releases.kubeprod.io/files/v1.3.0/manifests/platforms/eks.jsonnet") {
  config:: import "kubeprod-autogen.json",
  // Place your overrides here
 }
```

### Step 3: Perform the upgrade

Re-run the `kubeprod install` command from the [Deploy BKPR](#step-3-deploy-bkpr) step in the directory containing the existing `kubeprod-autogen.json` and updated `kubeprod-manifest.jsonnet` files.

## Teardown and cleanup

### Step 1: Uninstall BKPR from your cluster

  ```bash
  kubecfg delete kubeprod-manifest.jsonnet
  ```

### Step 2: Wait for the `kubeprod` namespace to be deleted

  ```bash
  # Specific finalizers cleanup, to avoid kubeprod ns lingering
  # - cert-manager challenges if TLS certs have not been issued
  kubectl get -n kubeprod challenges.acme.cert-manager.io -oname| \
    xargs -rtI{} kubectl patch -n kubeprod {} \
      --type=json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
  ```

  ```bash
  kubectl wait --for=delete ns/kubeprod --timeout=300s
  ```

### Step 3: Delete the Hosted Zone in Route 53

  ```bash
  BKPR_DNS_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "${BKPR_DNS_ZONE}" \
                                                           --max-items 1 \
                                                           --query 'HostedZones[0].Id' \
                                                           --output text)
  aws route53 list-resource-record-sets --hosted-zone-id ${BKPR_DNS_ZONE_ID} \
                                        --query '{ChangeBatch:{Changes:ResourceRecordSets[?Type != `NS` && Type != `SOA`].{Action:`DELETE`,ResourceRecordSet:@}}}' \
                                        --output json > changes
  aws route53 change-resource-record-sets --cli-input-json file://changes \
                                          --hosted-zone-id ${BKPR_DNS_ZONE_ID} \
                                          --query 'ChangeInfo.Id' \
                                          --output text
  aws route53 delete-hosted-zone --id ${BKPR_DNS_ZONE_ID} \
                                 --query 'ChangeInfo.Id' \
                                 --output text
  ```

  Additionally you should remove the NS entries configured at the domain registrar.

### Step 4: Delete the BKPR user

  ```bash
  ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)
  aws iam detach-user-policy --user-name "bkpr-${BKPR_DNS_ZONE}" --policy-arn "arn:aws:iam::${ACCOUNT}:policy/bkpr-${BKPR_DNS_ZONE}"
  aws iam delete-policy --policy-arn "arn:aws:iam::${ACCOUNT}:policy/bkpr-${BKPR_DNS_ZONE}"
  ACCESS_KEY_ID=$(jq -r .externalDns.aws_access_key_id kubeprod-autogen.json)
  aws iam delete-access-key --user-name "bkpr-${BKPR_DNS_ZONE}" --access-key-id "${ACCESS_KEY_ID}"
  aws iam delete-user --user-name "bkpr-${BKPR_DNS_ZONE}"
  ```

### Step 5: Delete the BKPR App Client

  ```bash
  USER_POOL=$(jq -r .oauthProxy.aws_user_pool_id kubeprod-autogen.json)
  CLIENT_ID=$(jq -r .oauthProxy.client_id kubeprod-autogen.json)
  aws cognito-idp delete-user-pool-client --user-pool-id "${USER_POOL}" --client-id "${CLIENT_ID}"
  ```

### Step 6: Delete the EKS cluster

  ```bash
  eksctl delete cluster --name ${AWS_EKS_CLUSTER}
  ```

## Useful links

- [BKPR FAQ](FAQ.md)
- [Troubleshooting](troubleshooting.md)
- [Application Developers Reference Guide](application-developers-reference-guide.md)