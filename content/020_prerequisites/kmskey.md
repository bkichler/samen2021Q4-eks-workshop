---
title: "Create an AWS KMS Custom Managed Key (CMK)"
chapter: false
weight: 32
---
***
### TEAM_NAME -> bash_profile

Run the following line in your Cloud9 terminal. When you get a newline with a prompt, type in your team's name.  
See below for an example, then run it yourself:
![readteamname](/images/prerequisites/read_teamname.png)
```bash
read TEAM_NAME
```

Test to check that your TEAM_NAME variable was entered correctly:
```bash
test -n "$TEAM_NAME" && echo TEAM_NAME is "$TEAM_NAME" || echo TEAM_NAME is not set
```

Add your TEAM_NAME variable to bash_profile:
```bash
echo "export AWS_REGION=${TEAM_NAME}" | tee -a ~/.bash_profile
```
***
### Create your CMK
Create a CMK for the EKS cluster to use when encrypting your Kubernetes secrets:
```bash
aws kms create-alias --alias-name alias/eksworkshop-"$TEAM_NAME" --target-key-id $(aws kms create-key --query KeyMetadata.Arn --output text)
```

Let's retrieve the ARN of the CMK to input into the create cluster command.

```bash
export MASTER_ARN=$(aws kms describe-key --key-id alias/eksworkshop-"$TEAM_NAME" --query KeyMetadata.Arn --output text)
```

We set the MASTER_ARN environment variable to make it easier to refer to the KMS key later.

Now, let's save the MASTER_ARN environment variable into the bash_profile

```bash
echo "export MASTER_ARN=${MASTER_ARN}" | tee -a ~/.bash_profile
```
