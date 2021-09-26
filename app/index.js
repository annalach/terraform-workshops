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
