# 8. Amazon Machine Image

{% code title="app/index.js" %}
```javascript
const express = require("express");
const { SecretsManager } = require("@aws-sdk/client-secrets-manager");
const { Pool } = require("pg");

const port = process.env.PORT;
const region = process.env.AWS_REGION || "eu-central-1";
const secretId = process.env.SECRET_ID;
const dbEndpoint = process.env.DB_ENDPOINT;

const app = express();
const secretsManager = new SecretsManager({
  region,
});

(async () => {
  try {
    const secret = await secretsManager.getSecretValue({ SecretId: secretId });
    const { name, username, password } = JSON.parse(secret.SecretString);
    const connectionString = `postgresql://${username}:${password}@${dbEndpoint}/${name}`;

    const pool = new Pool({
      connectionString,
    });

    app.get("/", async (req, res) => {
      try {
        const client = await pool.connect();
        const { rows } = await client.query("SELECT NOW()");
        client.release();
        res.send(`<h1>${rows[0].now}</h1>`);
      } catch (error) {
        client.release();
      }
    });

    app.listen(port, () => {
      console.log(`Listening on port ${port}`);
    });
  } catch (error) {
    process.exit(1);
  }
})();
```
{% endcode %}

{% code title="app/.nvmrc" %}
```javascript
16.3.0
```
{% endcode %}

{% code title="app/package.json" %}
```javascript
{
  "name": "app",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "@aws-sdk/client-secrets-manager": "^3.24.0",
    "express": "^4.17.1",
    "pg": "^8.7.1"
  }
}

```
{% endcode %}

{% code title="packer/ami.pkr.hcl" %}
```javascript
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "node-app"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "eu-central-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source      = "../app"
    destination = "~/app"
  }

  provisioner "shell" {
    script = "script.sh"
  }
}
```
{% endcode %}

{% code title="packer/script.sh" %}
```javascript
#!/bin/bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

command -v nvm

cd ~/app

nvm install

nvm use

nvm install-latest-npm

npm install
```
{% endcode %}

