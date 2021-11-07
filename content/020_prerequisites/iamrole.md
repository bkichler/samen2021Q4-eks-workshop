---
title: "Create an IAM role for your Workspace"
chapter: false
weight: 16
---

1. Follow [this deep link to create an IAM role with Administrator access](https://console.aws.amazon.com/iam/home#/roles$new?step=review&commonUseCase=EC2%2BEC2&selectedUseCase=EC2&policies=arn:aws:iam::aws:policy%2FAdministratorAccess&roleName=temp-rolename-PLEASE-CHANGE-ME).
1. Confirm that **AWS service** and **EC2** are selected, then click **Next: Permissions** to view permissions.
1. Confirm that **AdministratorAccess** is checked, then click **Next: Tags** to assign tags.
1. Take the defaults, and click **Next: Review** to review.
1. Replace the placeholder name with **eksworkshop-admin-<YOUR_TEAM_NAME>** for the Name (eg **eksworkshop-admin-leveren**), and click **Create role**.
![createrole](/images/prerequisites/createrole.png)
