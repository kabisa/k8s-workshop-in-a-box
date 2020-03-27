#!/usr/bin/env bash
set -e
USER="$1"

# Setup OS user
useradd -m "$USER" -s /bin/bash
passwd -d "$USER" # passwordless login

# Temp allow Docker to create kind cluster
usermod -aG docker $USER

sudo su $USER -c "kind create cluster --name $USER --config $(dirname $0)/kind-config.yaml"
echo -n "$(tput setaf 2)Configuring cluster... $(tput sgr0)"

sudo su $USER -c "kubectl cluster-info --context kind-$USER"
sudo su $USER -c "kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml"

# Assign a unique subnet to each cluster, counting down from 255
NUM_CLUSTERS=$(kind get clusters | wc -l)
CLUSTER_SUBNET=$(expr 255 - $NUM_CLUSTERS)
cat $(dirname $0)/metallb-config.yaml | sed "s/172.17.255.1-172.17.255.250/172.17.$CLUSTER_SUBNET.1-172.17.$CLUSTER_SUBNET.250/" > /tmp/metallb-config.yaml
sudo su $USER -c "kubectl apply -f /tmp/metallb-config.yaml"

# Start/Stop node scripts

cat << EOF > /home/$USER/kill-node-1
#!/usr/bin/env bash
docker stop $USER-worker
EOF
cat << EOF > /home/$USER/kill-node-2
#!/usr/bin/env bash
docker stop $USER-worker2
EOF

cat << EOF > /home/$USER/start-node-1
#!/usr/bin/env bash
docker start $USER-worker
EOF
cat << EOF > /home/$USER/start-node-2
#!/usr/bin/env bash
docker start $USER-worker2
EOF

# Allow read and exec by users only

chmod 705 /home/$USER/kill-node-1
chmod 705 /home/$USER/kill-node-2
chmod 705 /home/$USER/start-node-1
chmod 705 /home/$USER/start-node-2

# Allow passwordless sudo

cat << EOF > /etc/sudoers.d/$USER
$USER ALL=(ALL) NOPASSWD: /home/$USER/kill-node-1
$USER ALL=(ALL) NOPASSWD: /home/$USER/start-node-1
$USER ALL=(ALL) NOPASSWD: /home/$USER/kill-node-2
$USER ALL=(ALL) NOPASSWD: /home/$USER/start-node-2
EOF

# Cleanup
gpasswd -d $USER docker
rm /tmp/metallb-config.yaml
