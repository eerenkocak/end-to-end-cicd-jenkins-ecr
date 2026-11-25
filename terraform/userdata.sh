#!/bin/bash
set -euo pipefail

dnf update -y
dnf install -y git wget jq docker awscli --allowerasing
systemctl enable --now docker

JENKINS_URL="pkg.jenkins.io/redhat-stable"
wget -O /etc/yum.repos.d/jenkins.repo "https://${JENKINS_URL}/jenkins.repo"
rpm --import "https://${JENKINS_URL}/jenkins.io-2023.key"
dnf install -y java-21-amazon-corretto jenkins
usermod -aG docker jenkins
systemctl enable --now jenkins

docker pull aquasec/trivy:latest
systemctl restart jenkins
