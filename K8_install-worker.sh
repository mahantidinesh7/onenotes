#Licensed Materials - Property of IBM
#(C) Copyright IBM Corp. 2016, 2017. All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

# Use to install Kubernetes . Execute  sudo K8_Install.sh
	
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock
sudo ufw disable	

echo "Updating Ubuntu..."
apt-get update -y
#apt-get upgrade -y

echo "Install os requirements"

apt-get update && apt-get install -y apt-transport-https | tee -a $LOGFILE 2>&1
echo "Add Kubernetes repo..."
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - | tee -a $LOGFILE 2>&1
sh -c 'echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list' | tee -a $LOGFILE 2>&1 
apt-get update  | tee -a $LOGFILE 2>&1

echo "Installing Kubernetes requirements..."
apt-get install -y kubelet kubeadm kubectl docker.io kubernetes-cni| tee -a $LOGFILE 2>&1
sudo swapon -s
sudo swapoff -a

#systemctl daemon-reload
#systemctl restart kubelet
# For multipe worker node execute the above on multiple VM's and then run kubeadm join
