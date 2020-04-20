#!/usr/bin/env bash
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    jq \
    vim

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get install -y docker-ce docker-ce-cli containerd.io

curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64 \
  && chmod +x ./kind && mv kind /usr/local/bin/

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.2/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl && mv kubectl /usr/local/bin/

curl -L https://github.com/derailed/k9s/releases/download/v0.19.2/k9s_Linux_x86_64.tar.gz \
  | tar -zxvf - -C /usr/local/bin/ k9s

# https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files
echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.d/90-inotify.conf
echo "fs.inotify.max_user_instances=1024" >> /etc/sysctl.d/90-inotify.conf
sysctl --load /etc/sysctl.d/90-inotify.conf

# Allow passwordless SSH
sudo sed -i 's/nullok_secure/nullok/' /etc/pam.d/common-auth
sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
cat << EOF >> /etc/ssh/sshd_config
PermitEmptyPasswords yes
EOF

# Setup icanhazcluster user

useradd -m -s /bin/bash icanhazcluster
passwd -d icanhazcluster

cp $(dirname $0)/icanhazcluster.sh /home/icanhazcluster/icanhazcluster.sh
chmod +x /home/icanhazcluster/icanhazcluster.sh
chown icanhazcluster:icanhazcluster /home/icanhazcluster/icanhazcluster.sh
touch /home/icanhazcluster/clusters.txt

cat << EOF >> /etc/ssh/sshd_config
Match User icanhazcluster
        ForceCommand ~/icanhazcluster.sh
EOF

/etc/init.d/ssh reload
