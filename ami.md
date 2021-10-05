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

```javascript
$ packer init ami.pkr.hcl
```

```javascript
$ packer fmt ami.pkr.hcl
```

```javascript
$ packer validate ami.pkr.hcl
```

```javascript
$ packer build ami.pkr.hcl

amazon-ebs.ubuntu: output will be in this color.

==> amazon-ebs.ubuntu: Prevalidating any provided VPC information
==> amazon-ebs.ubuntu: Prevalidating AMI Name: node-app-20210927190235
    amazon-ebs.ubuntu: Found Image ID: ami-091f21ecba031b39a
==> amazon-ebs.ubuntu: Creating temporary keypair: packer_6152154c-f5ac-2af8-0381-c8dc39e2416f
==> amazon-ebs.ubuntu: Creating temporary security group for this instance: packer_6152154e-e22e-936d-fd26-b8d003f57cc3
==> amazon-ebs.ubuntu: Authorizing access to port 22 from [0.0.0.0/0] in the temporary security groups...
==> amazon-ebs.ubuntu: Launching a source AWS instance...
==> amazon-ebs.ubuntu: Adding tags to source instance
    amazon-ebs.ubuntu: Adding tag: "Name": "Packer Builder"
    amazon-ebs.ubuntu: Instance ID: i-00b36d26d99b514df
==> amazon-ebs.ubuntu: Waiting for instance (i-00b36d26d99b514df) to become ready...
==> amazon-ebs.ubuntu: Using SSH communicator to connect: 18.159.195.4
==> amazon-ebs.ubuntu: Waiting for SSH to become available...
==> amazon-ebs.ubuntu: Connected to SSH!
==> amazon-ebs.ubuntu: Uploading ../app => ~/app
==> amazon-ebs.ubuntu: Provisioning with shell script: script.sh
==> amazon-ebs.ubuntu:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
==> amazon-ebs.ubuntu:                                  Dload  Upload   Total   Spent    Left  Speed
==> amazon-ebs.ubuntu: 100 14926  100 14926    0     0   485k      0 --:--:-- --:--:-- --:--:--  502k
    amazon-ebs.ubuntu: => Downloading nvm from git to '/home/ubuntu/.nvm'
==> amazon-ebs.ubuntu: Cloning into '/home/ubuntu/.nvm'...
    amazon-ebs.ubuntu: => * (HEAD detached at FETCH_HEAD)
    amazon-ebs.ubuntu:   master
    amazon-ebs.ubuntu: => Compressing and cleaning up git repository
    amazon-ebs.ubuntu:
    amazon-ebs.ubuntu: => Appending nvm source string to /home/ubuntu/.bashrc
    amazon-ebs.ubuntu: => Appending bash_completion source string to /home/ubuntu/.bashrc
    amazon-ebs.ubuntu: => Close and reopen your terminal to start using nvm or run the following to use it now:
    amazon-ebs.ubuntu:
    amazon-ebs.ubuntu: export NVM_DIR="$HOME/.nvm"
    amazon-ebs.ubuntu: [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    amazon-ebs.ubuntu: [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    amazon-ebs.ubuntu: nvm
    amazon-ebs.ubuntu: Found '/home/ubuntu/app/.nvmrc' with version <16.3.0>
    amazon-ebs.ubuntu: Downloading and installing node v16.3.0...
==> amazon-ebs.ubuntu: Downloading https://nodejs.org/dist/v16.3.0/node-v16.3.0-linux-x64.tar.xz...
==> amazon-ebs.ubuntu: ######################################################################## 100.0%
==> amazon-ebs.ubuntu: Computing checksum with sha256sum
==> amazon-ebs.ubuntu: Checksums matched!
    amazon-ebs.ubuntu: Now using node v16.3.0 (npm v7.15.1)
    amazon-ebs.ubuntu: Creating default alias: default -> 16.3.0 (-> v16.3.0 *)
    amazon-ebs.ubuntu: Found '/home/ubuntu/app/.nvmrc' with version <16.3.0>
    amazon-ebs.ubuntu: Now using node v16.3.0 (npm v7.15.1)
    amazon-ebs.ubuntu: Attempting to upgrade to the latest working version of npm...
    amazon-ebs.ubuntu: * Installing latest `npm`; if this does not work on your node version, please report a bug!
    amazon-ebs.ubuntu:
==> amazon-ebs.ubuntu: npm notice
    amazon-ebs.ubuntu: removed 10 packages, changed 55 packages, and audited 258 packages in 3s
    amazon-ebs.ubuntu:
    amazon-ebs.ubuntu: 11 packages are looking for funding
    amazon-ebs.ubuntu:   run `npm fund` for details
    amazon-ebs.ubuntu:
    amazon-ebs.ubuntu: found 0 vulnerabilities
==> amazon-ebs.ubuntu: npm notice New minor version of npm available! 7.15.1 -> 7.24.1
==> amazon-ebs.ubuntu: npm notice Changelog: <https://github.com/npm/cli/releases/tag/v7.24.1>
==> amazon-ebs.ubuntu: npm notice Run `npm install -g npm@7.24.1` to update!
==> amazon-ebs.ubuntu: npm notice
    amazon-ebs.ubuntu: * npm upgraded to: v7.24.1
    amazon-ebs.ubuntu:
    amazon-ebs.ubuntu: added 132 packages, and audited 133 packages in 6s
    amazon-ebs.ubuntu:
    amazon-ebs.ubuntu: 3 packages are looking for funding
    amazon-ebs.ubuntu:   run `npm fund` for details
    amazon-ebs.ubuntu:
    amazon-ebs.ubuntu: found 0 vulnerabilities
==> amazon-ebs.ubuntu: Stopping the source instance...
    amazon-ebs.ubuntu: Stopping instance
==> amazon-ebs.ubuntu: Waiting for the instance to stop...
==> amazon-ebs.ubuntu: Creating AMI node-app-20210927190235 from instance i-00b36d26d99b514df
    amazon-ebs.ubuntu: AMI: ami-0cca38f651b773594
==> amazon-ebs.ubuntu: Waiting for AMI to become ready...
==> amazon-ebs.ubuntu: Terminating the source AWS instance...
==> amazon-ebs.ubuntu: Cleaning up any extra volumes...
==> amazon-ebs.ubuntu: No volumes to clean up, skipping
==> amazon-ebs.ubuntu: Deleting temporary security group...
==> amazon-ebs.ubuntu: Deleting temporary keypair...
Build 'amazon-ebs.ubuntu' finished after 5 minutes 4 seconds.

==> Wait completed after 5 minutes 4 seconds

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.ubuntu: AMIs were created:
eu-central-1: ami-0cca38f651b773594
```

