#!/bin/bash
# zealium.sh
# Installs smartnode on Ubuntu 16.04 LTS x64
# ATTENTION: The anti-ddos part will disable http, https and dns ports.


# Warning that the script will reboot the server
#echo "WARNING: This script will reboot the server when it's finished."
#printf "Press Ctrl+C to cancel or Enter to continue: "
#read IGNORE

cd
# Changing the SSH Port to a custom number is a good security measure against DDOS attacks
#printf "Custom SSH Port(Enter to ignore): "
#read VARIABLE
#_sshPortNumber=${VARIABLE:-22}

# Get a new privatekey by going to console >> debug and typing smartnode genkey
#printf "Masternode GenKey: "
#read _nodePrivateKey

# The RPC node will only accept connections from your localhost
_rpcUserName=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12 ; echo '')

# Choose a random and secure password for the RPC
_rpcPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

# Get the IP address of your vps which will be hosting the smartnode
_nodeIpAddress=$(ip route get 1 | awk '{print $NF;exit}')

echo "Creating 2GB temporary swap file...this may take a few minutes..."
sudo dd if=/dev/zero of=/swapfile bs=1M count=2000
sudo mkswap /swapfile
sudo chown root:root /swapfile
sudo chmod 0600 /swapfile
sudo swapon /swapfile

#make swap permanent
sudo echo "/swapfile none swap sw 0 0" >> /etc/fstab

# Install pre-reqs using apt-get
apt-get install automake -y && apt-get install build-essential -y && apt-get install libtool -y && apt-get install autotools-dev && apt-get install autoconf && apt-get install pkg-config && apt-get install libssl-dev -y && apt-get install libboost-all-dev -y && apt-get install libevent-dev -y && apt-get install software-properties-common
sudo apt-get -y update && sudo apt-get -y install build-essential libssl-dev libdb++-dev libboost-all-dev libcrypto++-dev libqrencode-dev libminiupnpc-dev libgmp-dev libgmp3-dev autoconf autogen automake libtool
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update
apt-get update && apt-get install libdb4.8-dev -y && apt-get install libdb4.8++-dev -y && apt-get install libminiupnpc-dev -y && apt-get install libzmq3-dev -y
apt-get install unzip

# Clone Mirai

wget https://github.com/bumbacoin/Mirai-Master/files/2147373/miraid-ubu64-v111.zip
chmod -R 777 miraid
chmod -R 777 mirai-cli

mnip=$(curl -s https://api.ipify.org)
# Make a new directory for zealium daemon
mkdir ~/.mirai/
touch ~/.mirai/mirai.conf

# Change the directory to ~/.mirai
cd ~/.mirai/

# Create the initial mirai.conf file
echo "rpcuser=${_rpcUserName}
rpcpassword=${_rpcPassword}
rpcallowip=127.0.0.1
server=1
daemon=1
staking=0
masternode=1
masternodeaddr=$mnip:14440
masternodeprivkey=4hDNMXmeUaWKsEHCMjZfBPgpsS6ZxwpvF6zf1bXNcvwPKX8eKN1
" > mirai.conf

# Change the SSH port
#sed -i "s/[#]\{0,1\}[ ]\{0,1\}Port [0-9]\{2,\}/Port ${_sshPortNumber}/g" /etc/ssh/sshd_config

# Firewall security measures
cd
#apt install ufw -y
#ufw disable
#ufw allow 9678
#ufw allow "$_sshPortNumber"/tcp
#ufw limit "$_sshPortNumber"/tcp
#ufw logging on
#ufw default deny incoming
#ufw default allow outgoing
#ufw --force enable

cd ./miraid
./mirai-cli getinfo

#Generate New Masternode Privkey and reconfigure zealium.conf
#_MNPRIVKEY=$(zealium-cli masternode genkey)
#read _MNPRIVKEY
#zealium-cli stop
#rm ~/.zealium/zealium.conf

# Change the directory to ~/.zealium
#cd ~/.zealium/

# Create the FINAL zealium.conf file
#echo "rpcuser=${_rpcUserName}
#rpcpassword=${_rpcPassword}
#rpcallowip=127.0.0.1
#rpcport=31090
#listen=1
#server=1
#daemon=1
#masternode=1
#masternodeprivkey=${_MNPRIVKEY}
#" > zealium.conf

#cd Zealium/src
#zealiumd
sleep 10s
echo "Check block count here with ./zealium-cli getinfo, Current block count details as below..."
#zealium-cli getinfo
echo "SUCCESS! Your zealiumd has started. Your local masternode.conf entry is below..."
echo "MN ${_nodeIpAddress}:31090 ${_MNPRIVKEY} TXHASH INDEX"