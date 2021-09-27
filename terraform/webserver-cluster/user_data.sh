#!/bin/bash
su ubuntu -c 'export PORT=${port} SECRET_ID=${db_secert_arn} DB_ENDPOINT=${db_endpoint} && nohup ~/.nvm/versions/node/v16.3.0/bin/node ~/app/index.js &'
