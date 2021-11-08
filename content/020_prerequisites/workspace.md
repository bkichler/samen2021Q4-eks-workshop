---
title: "Create a Workspace"
chapter: false
weight: 14
---

{{% notice warning %}}
The Cloud9 workspace should be built by an IAM user with Administrator privileges,
not the root account user. Please ensure you are logged in as an IAM user, not the root
account user.
{{% /notice %}}

{{% notice info %}}
A list of supported browsers for AWS Cloud9 is found [here]( https://docs.aws.amazon.com/cloud9/latest/user-guide/browsers.html).
{{% /notice %}}


<!---
{{% notice info %}}
This workshop was designed to run in the **Oregon (us-west-2)** region. **Please don't
run in any other region.** Future versions of this workshop will expand region availability,
and this message will be removed.
{{% /notice %}}
-->

{{% notice tip %}}
Ad blockers, javascript disablers, and tracking blockers should be disabled for
the cloud9 domain, or connecting to the workspace might be impacted.
Cloud9 requires third-party-cookies. You can whitelist the [specific domains]( https://docs.aws.amazon.com/cloud9/latest/user-guide/troubleshooting.html#troubleshooting-env-loading).
{{% /notice %}}

### Launch Cloud9 in your closest region:

{{< tabs name="Region" >}}
{{{< tab name="Oregon" include="us-west-2.md" />}}
{{< /tabs >}}

- Select **Create environment**
- Name it **eksworkshop**, click Next.
- Choose **t3.small** for instance type, take all default values and click **Create environment**

When it comes up, customize the environment by:

- Closing the **Welcome tab**
![c9before](/images/prerequisites/cloud9-1.png)
- Opening a new **terminal** tab in the main work area
![c9newtab](/images/prerequisites/cloud9-2.png)
- Closing the lower work area
![c9newtab](/images/prerequisites/cloud9-3.png)
- Your workspace should now look like this
![c9after](/images/prerequisites/cloud9-4.png)

{{% notice info %}}
If you intend to run all the sections in this workshop, it will be useful to have more storage available for all the repositories and tests.
{{% /notice %}}

### Increase the disk size on the Cloud9 instance

{{% notice note %}}
The following command adds more disk space to the root volume of the EC2 instance that Cloud9 runs on. Once the command completes, we reboot the instance and it could take a minute or two for the IDE to come back online.
{{% /notice %}}

```bash
pip3 install --user --upgrade boto3
export instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
python -c "import boto3
import os
from botocore.exceptions import ClientError 
ec2 = boto3.client('ec2')
volume_info = ec2.describe_volumes(
    Filters=[
        {
            'Name': 'attachment.instance-id',
            'Values': [
                os.getenv('instance_id')
            ]
        }
    ]
)
volume_id = volume_info['Volumes'][0]['VolumeId']
try:
    resize = ec2.modify_volume(    
            VolumeId=volume_id,    
            Size=30
    )
    print(resize)
except ClientError as e:
    if e.response['Error']['Code'] == 'InvalidParameterValue':
        print('ERROR MESSAGE: {}'.format(e))"
if [ $? -eq 0 ]; then
    sudo reboot
fi

```

### Share your environment with your team

#### Invite a user in the same account as the Environment
Use the instructions in this section to share an AWS Cloud9 development environment that you own in your AWS account with a user in that same account.

1. If the user you want to invite is not one of the following types of users, be sure the user you want to invite already has the corresponding environment member access role:
    - The **AWS account root user**.
    - An **IAM administrator user**.
    - A **user who belongs to an IAM group**, a user who assumes a role, or a federated user who assumes a role, and that group or role has the AWS managed policy AWSCloud9Administrator attached.

2. Open the environment that you own and want to invite the user to, if the environment isn't already open.
3. In the menu bar in the AWS Cloud9 IDE, do one of the following.
    - Choose **Window, Share**.
    - Choose **Share** (located next to the **Preferences** gear icon):
![c9share](/images/prerequisites/c9share.png)

4. In the **Share this environment** dialog box, for **Invite Members**, type one of the following.
    - To invite an **IAM user**, enter the name of the user.
    - To invite the **AWS account root user**, type ```arn:aws:iam::123456789012:root```, **replacing 123456789012 with your AWS account ID**.

5. To make this user a read-only member, choose **R**. To make this user read/write, choose **RW**.
6. Choose **Invite**.

{{% notice info %}}
If you make this user a read/write member, a dialog box is displayed, containing information about possibly putting your AWS security credentials at risk. The following information provides more background about this issue. You should share an environment only with those you trust. A read/write member may be able to use the AWS CLI, the aws-shell, or AWS SDK code in your environment to take actions in AWS on your behalf. Furthermore, if you store your permanent AWS access credentials within the environment, that member could potentially copy those credentials and use them outside of the environment. Removing your permanent AWS access credentials from your environment and using temporary AWS access credentials instead does not fully address this issue. It lessens the opportunity of the member to copy those temporary credentials and use them outside of the environment (as those temporary credentials will work only for a limited time). However, temporary credentials still enable a read/write member to take actions in AWS from the environment on your behalf.
{{% /notice %}}
