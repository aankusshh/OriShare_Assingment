## Problem Statement
Setup a CI/CD pipeline using the tools of your choice(or preferably the mentioned tools).
1. It should deploy a simple web application to a server on a code push to a repository.
2. The deployed web application should be reachable on any web browser.
3. Make it scalable such that when load increases the number of servers scale up and down making
sure the new servers have the updated code.

## Solution
### Project Setup
1. **Define the Application**: Identified the web application to be deployed, including its dependencies and environment requirements (Node.js).
2. **Version Control**: Ensured the application code is stored in a version control system (GitHub) for easy collaboration and tracking.

### Create a Role for CodeDeploy:
1. AWSCodeDeployRole
2. AmazonS3FullAccess (or create a custom policy for specific S3 access).

### Prepare the Deployment Environment
1. **Provision EC2 Instances**: Launched EC2 instances in the desired AWS region (ap-south-1) where the application will be deployed. Chose instance types based on the application's resource requirements.
2. **Install Required Software**:
   - **Installed the AWS CodeDeploy Agent**: Followed the official documentation to install the CodeDeploy agent on the EC2 instances, enabling them to communicate with the CodeDeploy service.
   - **Installed Necessary Runtimes**: Installed and configured the required software (Node.js) on the EC2 instances to support the application's execution.

### Create the CodeDeploy Application and Deployment Group
1. **Navigate to the AWS CodeDeploy Service**: Logged into the AWS Management Console and navigated to the CodeDeploy service.
2. **Create a New Application**: Defined a new application in CodeDeploy, specifying the application name and compute platform (e.g., EC2/On-Premises).
3. **Create a Deployment Group**: Set up a deployment group within the application, specifying the EC2 instances that will host the application. Instances were identified using tags or instance IDs. Also, selected the appropriate service role that grants CodeDeploy the necessary permissions.

### Create an S3 Bucket
Create a new bucket, Name it my-app-artifacts.

### Configure the AppSpec File
1. **Create the `appspec.yml` File**: In the version control repository, created an `appspec.yml` file to define the deployment process. This file specifies:
   - **File Locations**: The source and destination paths for the application files to be copied during deployment.
   - **Lifecycle Hooks**: The scripts to be executed at specific stages of the deployment process (e.g., `AfterInstall` to run post-installation tasks).
  Example `appspec.yml`:
```yaml
version: 0.0
os: linux
files:
  - source: /
    destination: /home/ec2-user/my-simple-web-app
hooks:
  AfterInstall:
    - location: scripts/start_server.sh
      timeout: 300
      runas: ubuntu
```
### Create Deployment Scripts
1.Write Deployment Scripts: Created scripts (e.g., start_server.sh) to handle application-specific tasks during deployment, such as:
  - Installing dependencies (e.g., npm install)
  - Starting the application server (e.g., node app.js)
  - Redirecting logs (e.g., > app.log 2>&1)
Ensure Executable Permissions: Made the script files executable using chmod +x scripts/start_server.sh to allow CodeDeploy to run them during deployment.
```
#!/bin/bash
cd /home/ec2-user/my-simple-web-app
npm install
nohup node app.js > app.log 2>&1 &
```

### Setup Jenkins
1. Install Jenkins on the jenkins server.
2. Install the following extra plugins:
  - AWS CodeDeploy Plugin
  - AWS CodeBuild Plugin
3. Go to "Manage Jenkins" -> "Manage Credentials". (for AWS and git)
4. Configure the Webhook (so if any changes occur in the git, the jenkins will get triggered and build the code automatically)
5. Set or Create the pipeline
```
pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'get-cred', url: 'https://github.com/aankusshh/OriShare_Assingment.git']])
            }
        }
        
        stage('Build') {
            steps {
                script {
                    // Build your application, e.g., using Docker or another build tool
                    sh 'npm install'
                }
            }
        }

        stage('Package') {
            steps {
                script {
                    // Package the application into a ZIP file
                    sh 'zip -r my-app.zip .'
                }
            }
        }
        
        stage('Upload to S3') {
            steps {
                script {
                    // Upload the ZIP file to the specified S3 bucket
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh 'aws s3 cp my-app.zip s3://my-app-artifacts/'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Install the latest version of the AWS CLI if not already installed
                    sh 'aws --version || ( curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo ./aws/install )'

                    // Use withCredentials to set AWS access key and secret key
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    // Set the AWS region as an environment variable
                    env.AWS_DEFAULT_REGION = 'ap-south-1'

                    // Create a new deployment in CodeDeploy
                    sh '''
                        aws deploy create-deployment \
                            --application-name MyWebApp \
                            --deployment-config-name CodeDeployDefault.OneAtATime \
                            --deployment-group-name MyDeploymentGroup \
                            --s3-location bucket=my-app-artifacts,bundleType=zip,key=my-app.zip
                    '''
                        }
                    }
                }
            }
        }
    }
    
```
# Troubleshooting and Issues Encountered
1. Initially I have created the t2.micro for jenkins but it will suddenly starts to slow down or sometimes not responding at all (I guess it can't able to handle the workload). So, I changed it to t2.small.
2. Got several ERROR while building the pipeline (like I have't downloaded many dependencied like ruby and many more) So after some research I came across this bash file which I used as extension in EC2 instances.
```
#!/bin/bash
sudo yum -y update
sudo yum -y install ruby
sudo yum -y install wget
cd /home/ec2-user
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto
sudo pip install awscli
```
3. Initially I was trying the deployment in Ubuntu server (but I don't know it doesn't get deploy, even though I tried everything) So, I changed the server to Amazon-linux (and deployment worked perfectly fine)



# Problem 2

## Solution 1
```
#!/bin/bash

# Base directory for projects
BASE_DIR="./projects"

# List of projects and their subdirectories
declare -A projects
projects=(
    ["facebook"]=""
    ["google"]="oriserve"
    ["meta"]="oriserve"
    ["oracle"]=""
)

# Create the project directories and files
for project in "${!projects[@]}"; do
    # Create the project directory
    PROJECT_DIR="$BASE_DIR/$project"
    mkdir -p "$PROJECT_DIR"  # Create project directory

    # Check if there is a subdirectory
    if [[ -n "${projects[$project]}" ]]; then
        SUBDIR="${projects[$project]}"
        SUBDIR_PATH="$PROJECT_DIR/$SUBDIR"
        
        # Create the subdirectory
        mkdir -p "$SUBDIR_PATH"  # Create oriserve directory

        # Create a file in the oriserve directory
        echo "oriserve" > "$SUBDIR_PATH/oriserve.txt"  # Create a file with the content "oriserve"
    fi
done

echo "Directory structure created successfully."
```


# Solution 2
```
#!/bin/bash

# Base directory for projects
BASE_DIR="./projects"

# Find all 'oriserve' directories and create 'test.txt' file in each
find "$BASE_DIR" -type d -name "oriserve" | while read -r oriserve_dir; do
    # Create the test.txt file in the oriserve directory
    echo "oriserve" > "$oriserve_dir/test.txt"
done

echo "test.txt files created successfully in all oriserve directories."
```

