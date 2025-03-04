---
title: "Launch EKS"
date: 2018-08-07T13:34:24-07:00
weight: 20
---


{{% notice warning %}}
**DO NOT PROCEED** with this step unless you have [validated the IAM role](/020_prerequisites/workspaceiam/#validate-the-iam-role) in use by the Cloud9 IDE. You will not be able to run the necessary kubectl commands in the later modules unless the EKS cluster is built using the IAM role.
{{% /notice %}}

#### Challenge:

**How do I check the IAM role on the workspace?**

{{%expand "Expand here to see the solution" %}}
Run `aws sts get-caller-identity` and validate that your _Arn_ contains `eksworkshop-"$TEAM_NAME"`and an Instance Id.

```output
{
    "Account": "123456789012",
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef",
    "Arn": "arn:aws:sts::123456789012:assumed-role/eksworkshop-"$TEAM_NAME"/i-01234567890abcdef"
}
```

If you do not see the correct role, please go back and [validate the IAM role](/020_prerequisites/workspaceiam/#validate-the-iam-role) for troubleshooting.

If you do see the correct role, proceed to next step to create an EKS cluster.
{{% /expand %}}

### Create an EKS cluster

{{% notice warning %}}
`eksctl` version must be 0.38.0 or above to deploy EKS 1.19, [click here](/030_eksctl/prerequisites) to get the latest version.
{{% /notice %}}

{{% notice warning %}}
Make sure you have already entered a value for the **TEAM_NAME** variable so your cluster is uniquely identified.
{{% /notice %}}

Create an eksctl deployment file (eksworkshop.yaml) use in creating your cluster using the following syntax:

```bash
cat << EOF > eksworkshop.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl-${TEAM_NAME}
  region: ${AWS_REGION}
  version: "1.21"

availabilityZones: ["${AZS[0]}", "${AZS[1]}"]

managedNodeGroups:
- name: nodegroup
  desiredCapacity: 3
  instanceType: t3.small
  ssh:
    enableSsm: true

# To enable all of the control plane logs, uncomment below:
# cloudWatch:
#  clusterLogging:
#    enableTypes: ["*"]

secretsEncryption:
  keyARN: ${MASTER_ARN}
EOF
```

Next, use the file you created as the input for the eksctl cluster creation.

```bash
eksctl create cluster -f eksworkshop.yaml
```

{{% notice info %}}
Launching EKS and all the dependencies will take approximately 15 minutes
{{% /notice %}}
