#!/bin/bash
apt-get update
apt update
apt install -y awscli

# Install kubectl
curl -LO https://dl.k8s.io/release/v1.23.6/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

# Install helm
curl -L https://git.io/get_helm.sh | bash -s -- --version v3.8.2
# Update kubeconfig
# aws configure set aws_access_key_id ${access_key} --profile ${profile_name}
# aws configure set aws_secret_access_key ${secret_key} --profile ${profile_name}
# aws configure set region ${region} --profile ${profile_name}
# aws configure set output ${output} --profile ${profile_name}
# aws eks update-kubeconfig --name ${cluster_name} --profile ${profile_name} --region ${region}
#aws eks update-kubeconfig --name eks_cluster --profile dev --region us-east-1