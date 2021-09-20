# 4. Secrets Manager

```bash
$ mkdir secrets
$ cd secrets
$ touch main.tf
```

{% code title="terraform-workshops/secrets/mainf.tf" %}
```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "random_string" "name" {
  length  = 16
  special = false
}

resource "random_string" "username" {
  length  = 16
  special = false
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
    name     = random_string.name.result
    username = random_string.username.result
    password = random_password.password.result
  })
}
```
{% endcode %}

```bash
$ touch outputs.tf
```

{% code title="terraform-workshops/secrets/outputs.tf" %}
```bash
output "db_secert_arn" {
  value = aws_secretsmanager_secret_version.db_secret_version.arn
}
```
{% endcode %}

```bash
$ terraform init
$ terraform apply

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

db_secert_arn = "arn:aws:secretsmanager:eu-central-1:852046301552:secret:db-secret-Je6HqeVPr6c=-Wi3YY3"
```

```bash
$ aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:eu-central-1:852046301552:secret:db-secret-Je6HqeVPr6c=-Wi3YY3

{
    "ARN": "arn:aws:secretsmanager:eu-central-1:852046301552:secret:db-secret-Je6HqeVPr6c=-Wi3YY3",
    "Name": "db-secret-Je6HqeVPr6c=",
    "VersionId": "7C8DBD19-D7AC-47D9-94D7-41081C0D1C61",
    "SecretString": "{\"name\":\"nrolhkUfmoqjHBhF\",\"password\":\"zilJqjnsbhvDvHzs\",\"username\":\"N2FSa67lDzlaSQkB\"}",
    "VersionStages": [
        "AWSCURRENT"
    ],
    "CreatedDate": "2021-09-20T21:48:32.260000+02:00"
}
```

The example code from this section is available [here](https://github.com/annalach/terraform-workshops/tree/master/terraform-workshops/secrets).

