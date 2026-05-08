#!/bin/bash

exec > /var/log/user-data.log 2>&1

set -eux

# Update system
apt update -y

# Install dependencies
apt install -y \
    fontconfig \
    openjdk-17-jre \
    wget \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    software-properties-common \
    snapd

# ---------------- Jenkins ----------------

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
-o /tmp/jenkins.key

gpg --dearmor --yes \
-o /usr/share/keyrings/jenkins-keyring.gpg \
/tmp/jenkins.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] \
https://pkg.jenkins.io/debian-stable binary/" \
> /etc/apt/sources.list.d/jenkins.list

apt update -y
apt install -y jenkins

systemctl enable jenkins
systemctl start jenkins

# ---------------- Docker ----------------

apt install -y docker.io

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu
usermod -aG docker jenkins

# ---------------- Trivy ----------------

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
| gpg --dearmor --yes -o /usr/share/keyrings/trivy.gpg

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb noble main" \
> /etc/apt/sources.list.d/trivy.list

apt update -y
apt install -y trivy

# ---------------- AWS CLI ----------------

snap install aws-cli --classic || true

# ---------------- Helm ----------------

snap install helm --classic || true

# ---------------- Kubectl ----------------

snap install kubectl --classic || true

systemctl restart docker
systemctl restart jenkins
