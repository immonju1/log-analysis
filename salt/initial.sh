# Install prerequisites
apt-get update
apt-get install -y dpkg-dev default-jre

# Make folder for local repository
mkdir /srv/local-repo
cd /srv/local-repo

# Download packages (6.4.2 for plugin compatibility)
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.2.deb
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.4.2-amd64.deb
wget https://artifacts.elastic.co/downloads/logstash/logstash-6.4.2.deb

# Create repo
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
echo "deb file:/srv/local-repo ./" | tee -a /etc/apt/sources.list

# Install
apt-get update
apt-get install -y elasticsearch kibana logstash --allow-unauthenticated
