#!/bin/bash

echo "======================================"
echo " SonarQube + PostgreSQL Setup Started "
echo "======================================"

# Update system
sudo apt update -y

# Install Java
echo "Installing Java..."
sudo apt install openjdk-17-jdk -y

# Install PostgreSQL
echo "Installing PostgreSQL..."
sudo apt install postgresql postgresql-contrib -y

# Start and enable PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create SonarQube DB & User
echo "Configuring PostgreSQL for SonarQube..."
sudo -u postgres psql <<EOF
CREATE DATABASE sonarqube;
CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar123';
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
EOF

# Create sonar user
echo "Creating sonar system user..."
sudo useradd -m -s /bin/bash sonar

# Download SonarQube
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.3.79811.zip

# Install unzip
sudo apt install unzip -y

# Extract SonarQube
sudo unzip sonarqube-9.9.3.79811.zip
sudo mv sonarqube-9.9.3.79811 sonarqube

# Set ownership
sudo chown -R sonar:sonar /opt/sonarqube
sudo chmod -R 755 /opt/sonarqube

# Configure SonarQube DB
echo "Configuring SonarQube database..."
sudo sed -i "s|#sonar.jdbc.username=|sonar.jdbc.username=sonar|" /opt/sonarqube/conf/sonar.properties
sudo sed -i "s|#sonar.jdbc.password=|sonar.jdbc.password=sonar123|" /opt/sonarqube/conf/sonar.properties
sudo sed -i "s|#sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube|sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube|" /opt/sonarqube/conf/sonar.properties

# Kernel parameters (required)
echo "Setting vm.max_map_count..."
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072

# Start SonarQube
echo "Starting SonarQube..."
sudo -u sonar /opt/sonarqube/bin/linux-x86-64/sonar.sh start

echo "======================================"
echo " SonarQube Started Successfully "
echo " URL: http://13.233.174.189:9000 "
echo "======================================"
