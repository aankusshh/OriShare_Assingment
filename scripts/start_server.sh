# #!/bin/bash
# cd /home/ubuntu/my-simple-web-app
# npm install
# nohup node app.js > app.log 2>&1 &


#!/bin/bash
cd /home/ec2-user/my-simple-web-app
npm install
nohup node app.js > app.log 2>&1 &
