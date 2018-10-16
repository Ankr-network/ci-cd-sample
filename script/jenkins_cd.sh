#!/bin/sh
ssh ubuntu@13.57.223.53 /bin/bash <<'EOT'
cd ~/ci-cd-sample
git pull
npm install
pm2 restart all
EOT

