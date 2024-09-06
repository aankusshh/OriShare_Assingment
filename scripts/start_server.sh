#!/bin/bash
cd /home/ubuntu/my-simple-web-app
npm install
nohup node app.js > app.log 2>&1 &
