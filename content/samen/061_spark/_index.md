---
title: "BONUS: Deploy Spark to EKS"
chapter: true
weight: 61
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
tags:
  - samen
  - CON203
  - CON205
  - CON206
---

# Spark on Kubernetes

{{% notice info %}}
This tutorial has been updated for Helm v3 & uses [Bitnami Kubernetes Production Runtime for EKS](https://github.com/bitnami/kube-prod-runtime)
{{% /notice %}}

[Helm](https://helm.sh/) is a package manager for Kubernetes that packages
multiple Kubernetes resources into a single logical deployment unit called
a **Chart**. Charts are easy to create, version, share, and publish.

[Apache Spark](https://https://spark.apache.org/) is a multi-language engine 
for executing data engineering, data science, and machine learning on 
single-node machines or clusters.
