# Introduction

## Amazon Web Services

### AWS Free Tier

AWS allows to explore more than 100 products and start building on AWS using the Free Tier. You can check the details [here](https://aws.amazon.com/free). Using AWS Free Tier, we will benefit from:

* Amazon EC2 - **750 hours** per month of Linux **t2.micro**
* Amazon RDS - **750 hours** per month of PostgreSQL **db.t2.micro** database usage and **20 GB** of General Purpose \(SSD\) database storage

### Services not covered by the Free Tier

Charges that you may incur because of these workshops should not exceed **1$**. You may be charged because of the following services we will use:

* Application Load Balancer
* CloudWatch
* VPC Endpoint
* Secrets Manager

We will destroy all resources at the end of the workshops.

### Infrastructure we will build

consists of:

* Virtual Private Cloud with:
  * 4 subnets \(2 public and 2 private\)
  * Internet Gateway
  * 2 Route Tables
  * VPC Endpoint
* Application Load Balancer
* Auto Scaling Group
* Relational Database Service
* Security Groups

![](.gitbook/assets/screen-shot-2021-10-08-at-16.17.44.png)

## "Infrastructure as Code" tools we will use

### Terraform

### Packer

