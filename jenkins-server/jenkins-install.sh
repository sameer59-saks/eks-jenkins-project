#!/bin/bash
set -e

# Function to print messages
print_message() {
    echo "================================================"
    echo "$1"
    echo "================================================"
}

# Function to check command status
check_status() {
    if [ $? -eq 0 ]; then
        echo "✅ $1 successful"
    else
        echo "❌ $1 failed"
        exit 1
    fi
}

# Update system
print_message "Updating system"
sudo apt update && sudo apt upgrade -y
check_status "System update"

# Install Java for Jenkins
print_message "Installing Java"
sudo apt install openjdk-11-jre -y
check_status "Java installation"

# Install Jenkins
print_message "Installing Jenkins"
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
check_status "Jenkins installation"

# Start Jenkins and enable it to run on boot
sudo systemctl start jenkins
sudo systemctl enable jenkins
check_status "Jenkins service start"

# Install Terraform
print_message "Installing Terraform"
sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform -y
check_status "Terraform installation"

# Install Kubernetes CLI (kubectl)
print_message "Installing Kubernetes CLI (kubectl)"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
check_status "kubectl installation"

# Install AWS CLI
print_message "Installing AWS CLI"
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
check_status "AWS CLI installation"

print_message "Installation complete!"

# Print versions
print_message "Installed versions:"
java -version
jenkins --version
terraform --version
kubectl version --client
aws --version

# Final Jenkins service status check
print_message "Jenkins service status:"
sudo systemctl status jenkins

print_message "Installation script finished. Please check above for any errors."