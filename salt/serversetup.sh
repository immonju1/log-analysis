#!/bin/bash
#Simple logging server

# Complete basic setup
echo "Setting Finnish keyboard layout..."
setxkbmap fi
cd ~
echo "Setting keyboard mapping to finnish.."
setxkbmap fi
echo "Updating packages..."
apt-get update -qq >> /dev/null
echo "Installing git and salt..."
apt-get install git salt-master salt-minion -y -qq >> /dev/null
echo "Cloning repository..."
git clone -b sakutesti https://github.com/jisosomppi/log-analysis/
echo "Running automated setup... (This will take a while)"

# Create directories
if [ ! -d "/srv/" ]; then
mkdir /srv/
fi 

# Place Salt files
mkdir /srv/salt /srv/pillar
cp -R log-analysis/salt/srvsalt/* /srv/salt
cp -R log-analysis/salt/srvpillar/* /srv/pillar
cp log-analysis/salt/saltmaster /etc/salt/minion
sudo mv log-analysis/downloads/readonlyrest-1.16.28_es6.4.2.zip /tmp/

# Get rid of annoying warning & restart services
echo -e "\nfile_ignore_glob: []\n" >> /etc/salt/master
systemctl restart salt-minion
systemctl restart salt-master

# Create OpenSSL keys for Nginx
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Haaga-Helia/OU=Logserver/CN=logserver.local"
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Run salt state for master (forcing id because local salt key is not signed yet)
salt-call --local --id srv01 state.highstate --state-output terse -l quiet

# Print instructions
echo "Server setup is now complete!"
echo "Direct your clients to this servers IP address:"
hostname -I
echo
echo
echo "Collected client logs will be found in /var/log/client_logs"
echo "Run 'sudo salt srv01 state.apply fixperms' when new host directories or log files are created"
echo
echo "Opening the logging frontend at http://logserver.local (This address also works on connected Salt minions)"
firefox http://logserver.local
