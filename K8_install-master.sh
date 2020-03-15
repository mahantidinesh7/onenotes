#Licensed Materials - Property of IBM
#(C) Copyright IBM Corp. 2016, 2017. All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CMD=$(basename $0)
LOG_DIR=log/${CMD%.*}
LOGFILE=${LOG_DIR}/${CMD%.*}_$(date +%Y%m%d%H%M).log
sudo mkdir -p ${LOG_DIR}
sudo chmod 777 $LOG_DIR	
	
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
reset=`tput sgr0`
	
echo "Root directory = $BASE_DIR" | tee -a $LOGFILE 2>&1
echo "Date is: `date`" | tee -a $LOGFILE 2>&1
echo "You logged in as: `whoami`" >> $LOGFILE 2>&1
	
# Use to install Kubernetes . Execute  sudo K8_Install.sh
	
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock
sudo ufw disable | tee -a $LOGFILE 2>&1

echo "${green} Updating Ubuntu...${reset}" | tee -a $LOGFILE 2>&1
apt-get update -y | tee -a $LOGFILE 2>&1
#apt-get upgrade -y

echo "${green} Install os requirements ${reset}" | tee -a $LOGFILE 2>&1
apt-get update && apt-get install -y apt-transport-https | tee -a $LOGFILE 2>&1

echo "${green} Add Kubernetes repo... ${reset}" | tee -a $LOGFILE 2>&1
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - | tee -a $LOGFILE 2>&1
sh -c 'echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list' | tee -a $LOGFILE 2>&1
apt-get update  | tee -a $LOGFILE 2>&1

echo "${green} Installing Kubernetes requirements... ${reset}" | tee -a $LOGFILE 2>&1
apt-get install -y kubelet kubeadm kubectl docker.io kubernetes-cni | tee -a $LOGFILE 2>&1

sudo swapon -s
sudo swapoff -a
echo "${green} kubeadm init ${reset}" | tee -a $LOGFILE 2>&1
kubeadm init --pod-network-cidr=172.16.0.0/16| tee -a $LOGFILE 2>&1
	
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#echo "${green} Installing Flannel ${reset}" | tee -a $LOGFILE 2>&1
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml | tee -a $LOGFILE 2>&1

#echo "${green} Installing Flannel rbac ${reset}" | tee -a $LOGFILE 2>&1
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml | tee -a $LOGFILE 2>&1

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
#kubectl apply -f https://git.io/weave-kube-1.6
# For multipe worker node execute the above on multiple VM's and then run kubeadm join
