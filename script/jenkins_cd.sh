#!/bin/sh

ssh ubuntu@13.57.223.53 <<EOF
 cd ~/ci-cd-sample
 git pull
 npm install
 pm2 restart all
 exit
EOF

