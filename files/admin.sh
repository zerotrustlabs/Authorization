#!/usr/bin/env bash

echo "--> Setting hostname..."
echo "${hostname}" | sudo tee /etc/hostname
sudo hostname -F /etc/hostname

echo "--> Adding hostname to /etc/hosts"
sudo tee -a /etc/hosts > /dev/null <<EOF

# For local resolution
$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)  ${hostname}
EOF

echo "--> Create new user, edit ssh settings"
 
sudo useradd ${username} \
   --shell /bin/bash \
   --create-home 
echo '${username}:${ssh_pass}' | sudo chpasswd
sudo sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

sudo service sshd reload

echo "Adding ${username} user to sudoers"
sudo tee /etc/sudoers.d/${username} > /dev/null <<"EOF"
${username} ALL=(ALL:ALL) ALL
EOF
sudo chmod 0440 /etc/sudoers.d/${username}
sudo usermod -a -G sudo ${username}

sudo yum install -y yum-utils
sudo yum update

sudo yum -y install jq git

#New
sudo yum install docker -y
sudo mkdir -p /usr/local/lib/docker/cli-plugins/
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

#Untouched
sudo systemctl start docker
sudo usermod -a -G docker ${username}
sudo systemctl enable docker

# Run Wetty (changed port from 80 to 5050)
echo "running wetty container"
docker run --rm -p 80:3000 --detach wettyoss/wetty --ssh-host=172.17.0.1 --ssh-user ${username}

# Getting Repo
echo "Setting workdir and cloning repo"
sudo mkdir /home/${username}/workdir
cd /home/${username}/workdir
sudo git clone ${gitrepo}
sudo chown -R ${username}:${username} /home/${username}/workdir

# Run VS code
echo "running VS code container"
sudo docker run -dit -p 8000:8080 \
  -v "$PWD:/home/coder/project" \
  -v "$HOME/.local/share/code-server/User:/home/coder/.local/share/code-server/User" \
  -u "$(id -u):$(id -g)" \
  --detach \
  codercom/code-server:latest --auth none

echo "Waiting for codercom/code-server container to be up..."

# Wait for the container to start running
while [ -z "$(sudo docker ps -aqf 'ancestor=codercom/code-server:latest')" ]; do
  sleep 1
done

echo "codercom/code-server container is running"

# Get container id
CONTAINER_ID=$(sudo docker ps -aqf "ancestor=codercom/code-server:latest")

# Set dark mode
sudo docker exec $CONTAINER_ID sh -c "cd & echo '{\"workbench.colorTheme\": \"Visual Studio Dark\"}' > /root/.local/share/code-server/User/settings.json"

# Installing kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo yum install -y kubectl

# download istio
cd /home/${username}
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.18.0 TARGET_ARCH=x86_64 sh -
sudo cp /home/${username}/istio-1.18.0/bin/istioctl /usr/local/bin/istioctl
sudo chmod +x /usr/local/bin/istioctl

# add kube config 
sudo -u ${username} sh -c 'mkdir /home/${username}/.kube'
echo "${cube_config}" > /home/${username}/.kube/config
sudo sed -i "/cluster: cool-panda-aks$/a\    namespace: ${panda_name}" /home/${username}/.kube/config
cp -R /home/${username}/.kube /root/

# create namespace
echo "# Create Namespace"
sudo kubectl create namespace ${panda_name}

sudo -u ${username} sh -c 'mkdir /home/${username}/workdir/${panda_name}'

echo "source <(kubectl completion bash)" >> /home/${username}/.bashrc 

# Download OPA
cd /home/${username}
curl -L -o opa https://openpolicyagent.org/downloads/v0.54.0/opa_linux_amd64_static
chmod 755 ./opa
sudo mv opa /usr/local/bin/

cd /home/${username}/workdir/${panda_name}
git clone https://github.com/DevOpsPlayground/zero-trust-kube-yamls.git .

panda=$(echo "${panda_name}" | sed 's/-//g')
sed -i "s/\pname/$panda/g; s/\panda_name/${panda_name}/g" /home/${username}/workdir/${panda_name}/set-istio-config.yaml
sed -i "s/\provider_name/$panda/g; s/\panda_name/${panda_name}/g" /home/${username}/workdir/${panda_name}/auth-policy.yaml

echo "# install istio"
sudo /usr/local/bin/istioctl install -f istio.yaml --set values.global.logging.level=debug -y
sleep 120 
sudo /usr/local/bin/istioctl install -f ingress.yaml --set values.global.logging.level=debug -y 
sleep 120 

sudo kubectl label namespace ${panda_name} istio-injection=enabled

add_ext_provider() {
  if [[ ! $(sudo kubectl get configmap istio -n istio-system -o yaml | grep -c "extensionProviders:")  -ge 1 ]]; then
    echo "# ExtensionsProvider does not exists...Adding Extensions Provider to meshconfig"
    sudo kubectl get configmap istio -n istio-system -o yaml | sed '0,/enablePrometheusMerge: true/s//&\n \ \ \ \extensionProviders:/'| kubectl apply -f -
    return 1
  else
    echo "# ExtensionsProvider exist in mesh config....skipping"
    return 0
  fi
}

while ! add_ext_provider; do
  echo "Extensions Provider - Condition is not true yet. Waiting..."
  sleep 3 # 
done