# 4. Secrets Manager

{% code title="terraform/secrets/mainf.tf" %}
```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.62.0"
    }
  }

  required_version = ">= 1.0.8"
}

provider "aws" {
  region = "eu-central-1"
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_id" "db_secret_suffix" {
  byte_length = 8
}

resource "aws_secretsmanager_secret" "db_secret" {
  name = "db-secret-${random_id.db_secret_suffix.b64_std}"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    name     = "workshopsdb"
    username = "workshopsuser"
    password = random_password.password.result
  })
}

```
{% endcode %}

{% code title="terraform/secrets/outputs.tf" %}
```bash
output "db_secert_arn" {
  value = aws_secretsmanager_secret_version.db_secret_version.arn
}
```
{% endcode %}

Try to read the secret's value using the AWS CLI:

```bash
$ aws secretsmanager get-secret-value --secret-id aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:eu-central-1:852046301552:secret:db-secret-WNqgLUG8tGI=-5EzeJ8

{
    "ARN": "arn:aws:secretsmanager:eu-central-1:852046301552:secret:db-secret-WNqgLUG8tGI=-5EzeJ8",
    "Name": "db-secret-WNqgLUG8tGI=",
    "VersionId": "4FF5D96B-24A9-4712-804B-BCD4D1AF3D6B",
    "SecretString": "{\"name\":\"workshopsdb\",\"password\":\"iypoEyxNfmcWeqnZ\",\"username\":\"workshopsuser\"}",
    "VersionStages": [
        "AWSCURRENT"
    ],
    "CreatedDate": "2021-10-17T21:08:18.435000+02:00"
}
```

Our application will need to read the secret's value to be able to connect to the database. We need to make sure we can read the secret's value from the EC2 instance which is running in the private subnet. First, we need to create IAM Role that the EC2 instance will use.

{% hint style="info" %}
IAM Role is a way of giving some privileges to some AWS resource to let it do something with another AWS resource.
{% endhint %}
