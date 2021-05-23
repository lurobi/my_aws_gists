#!/bin/sh

function killService() {
    service=$1
    sudo systemctl stop $service
    sudo systemctl kill --kill-who=all $service
}

function disableTimers() {
    sudo systemctl disable apt-daily.timer
    sudo systemctl disable apt-daily-upgrade.timer
}

function enableTimers() {
    sudo systemctl enable apt-daily.timer
    sudo systemctl enable apt-daily-upgrade.timer
}

function killServices() {
    killService unattended-upgrades.service
    killService apt-daily.service
    killService apt-daily-upgrade.service
}

disableTimers
killServices


# Bring us up to date.
#sudo apt-get update
#apt-get upgrade

# install some useful tools
sudo apt-get install -y make screen binutils git wget curl emacs-nox

git clone https://github.com/aws/efs-utils /tmp/efs-utils
cd /tmp/efs-utils
./build-deb.sh
sudo apt install -y ./build/amazon-efs-utils*deb
cd ~
rm -rf /tmp/efs-utils


# mount my EFS at /mount/efs
sudo mkdir -p /mnt/efs
#sudo mount -t efs -o tls fs-849865ff:/ /mnt/efs
sudo bash -c "echo 'fs-849865ff:/ /mnt/efs           efs    _netdev,noresvport,tls  0 0' >> /etc/fstab"
sudo mount /mnt/efs

wget https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/SetupMinecraft.sh
chmod +x SetupMinecraft.sh
ln -s /mnt/efs/minecraftbe minecraftbe
./SetupMinecraft.sh

enableTimers
