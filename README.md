# EC2 Instance Launcher

This script launches an EC2 instance, sets up Docker, and runs an Nginx container.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Docker installed locally
- SSH key pair named `key-v.pem` in the same directory

## Usage

1. Ensure `user_data.sh` is in the same directory.
2. Run the script with a tag name: ./script_name.sh `<tag-name>`
3. Wait for the instance to launch and the Nginx server to start.
4. Access the Nginx server at the displayed URL.
5. Press 's' to terminate the instance when done.

Note: Ensure all AWS resource IDs in the script are correct for your account.
