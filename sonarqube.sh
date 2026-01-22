#!/bin/bash

echo "===== SonarQube Installation Started ====="

SONAR_VERSION="9.9.3.79811"
SONAR_USER="sonar"
SONAR_DIR="/opt/sonarqube"
SONAR_DB="sonarqube"
SONAR_DB_USER="sonar"
SONAR_DB_PASS="sonar123"

# Update system
sudo apt update -y

# Install dependencies
sudo apt install -y openjdk-17-jdk unzip wget postgresql postgresql-contrib

# ---------------------------
# Kernel parameter (ONLY required one)
# ---------------------------
sudo sysctl -w vm.max_map_count=524288

if ! grep -q "vm.max_map_count" /etc/sysctl.conf; then
  echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf
fi

# ---------------------------
# PostgreSQL setup
# ---------------------------
sudo systemctl enable postgresql
sudo systemctl start postgresql

sudo -u postgres psql <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '$SONAR_DB') THEN
      CREATE DATABASE $SONAR_DB;
   END IF;
END
\$\$;

DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$SONAR_DB_USER') THEN
      CREATE USER $SONAR_DB_USER WITH PASSWORD '$SONAR_DB_PASS';
   END IF;
END
\$\$;

ALTER DATABASE $SONAR_DB OWNER TO $SONAR_DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $SONAR_DB TO $SONAR_DB_USER;
EOF

# ---------------------------
# Create sonar user safely
# ---------------------------
if ! id sonar &>/dev/null; then
  sudo useradd -r -m -d /opt/sonarqube -s /bin/bash sonar
fi

# ---------------------------
# Install SonarQube
# ---------------------------
cd /opt || exit 1

if [ ! -d "$SONAR_DIR" ]; then
  sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip
  sudo unzip sonarqube-${SONAR_VERSION}.zip
  sudo mv sonarqube-${SONAR_VERSION} sonarqube
fi

sudo chown -R sonar:sonar $SONAR_DIR

# ---------------------------
# Configure SonarQube
# ---------------------------
sudo tee $SONAR_DIR/conf/sonar.properties <<EOF
sonar.jdbc.username=$SONAR_DB_USER
sonar.jdbc.password=$SONAR_DB_PASS
sonar.jdbc.url=jdbc:postgresql://localhost/$SONAR_DB
sonar.web.port=9000
EOF

# ---------------------------
# systemd service (SAFE LIMITS)
# ---------------------------
sudo tee /etc/systemd/system/sonarqube.service <<EOF
[Unit]
Description=SonarQube
After=network.target postgresql.service

[Service]
Type=forking
ExecStart=$SONAR_DIR/bin/linux-x86-64/sonar.sh start
ExecStop=$SONAR_DIR/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always

# SAFE limits (service-level only)
LimitNOFILE=131072
LimitNPROC=8192

[Install]
WantedBy=multi-user.target
EOF

# ---------------------------
# Start SonarQube
# ---------------------------
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl restart sonarqube

echo "===== SonarQube Installed Successfully ====="
echo "Access: http://13.234.118.180:9000"
