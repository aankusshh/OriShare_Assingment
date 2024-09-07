# #!/bin/bash
# cd /home/ubuntu/my-simple-web-app
# npm install
# nohup node app.js > app.log 2>&1 &


#!/bin/bash

# Set the application directory
APP_DIR="/home/ubuntu/my-simple-web-app"

# Navigate to the application directory
if [ -d "$APP_DIR" ]; then
    cd "$APP_DIR" || exit 1
else
    echo "Error: Application directory $APP_DIR does not exist." >&2
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
if npm install; then
    echo "Dependencies installed successfully."
else
    echo "Error: npm install failed." >&2
    exit 1
fi

# Start the application
echo "Starting the application..."
if nohup node app.js > app.log 2>&1 &; then
    echo "Application started successfully."
else
    echo "Error: Failed to start the application." >&2
    exit 1
fi

# Optionally, you can print the PID of the application
echo "Application is running with PID: $!"
