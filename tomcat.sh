#!/usr/bin/env bash

set -Eeuo pipefail

trap 'echo "ERROR: Script failed at line $LINENO."' ERR

# The script must run as root.
if [[ $EUID -ne 0 ]]; then
    echo "Run this script using:"
    echo "sudo bash tomcat.sh"
    exit 1
fi

TOMCAT_VERSION="9.0.120"
TOMCAT_HOME="/usr/local/tomcat"
APP_DIR="/opt/sourcecodeseniorwr"
APP_PROPERTIES="src/main/resources/application.properties"

echo "========================================"
echo "Installing required packages"
echo "========================================"

dnf clean all
dnf makecache

dnf install -y \
    java-11-amazon-corretto-devel \
    git \
    maven \
    wget \
    tar \
    gzip

echo "Checking installed packages..."

java -version
javac -version
git --version
mvn -version
wget --version | head -n 1

# Determine the actual Java 11 installation directory.
JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")"

export JAVA_HOME
export PATH="${JAVA_HOME}/bin:${PATH}"

echo "JAVA_HOME=${JAVA_HOME}"

echo "========================================"
echo "Stopping old Tomcat installation"
echo "========================================"

systemctl stop tomcat 2>/dev/null || true

echo "========================================"
echo "Creating Tomcat user"
echo "========================================"

if ! id tomcat >/dev/null 2>&1; then
    useradd \
        --system \
        --home-dir "${TOMCAT_HOME}" \
        --shell /sbin/nologin \
        tomcat
else
    echo "Tomcat user already exists."
fi

echo "========================================"
echo "Downloading Apache Tomcat"
echo "========================================"

cd /tmp

rm -f "apache-tomcat-${TOMCAT_VERSION}.tar.gz"

wget \
    "https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

echo "========================================"
echo "Installing Apache Tomcat"
echo "========================================"

rm -rf "${TOMCAT_HOME}"
mkdir -p "${TOMCAT_HOME}"

tar \
    -xzf "apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
    --strip-components=1 \
    -C "${TOMCAT_HOME}"

chown -R tomcat:tomcat "${TOMCAT_HOME}"

chmod +x \
    "${TOMCAT_HOME}/bin/startup.sh" \
    "${TOMCAT_HOME}/bin/shutdown.sh" \
    "${TOMCAT_HOME}/bin/catalina.sh"

echo "========================================"
echo "Creating Tomcat systemd service"
echo "========================================"

cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network-online.target
Wants=network-online.target

[Service]
Type=simple

User=tomcat
Group=tomcat

Environment="JAVA_HOME=${JAVA_HOME}"
Environment="CATALINA_HOME=${TOMCAT_HOME}"
Environment="CATALINA_BASE=${TOMCAT_HOME}"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

ExecStart=${TOMCAT_HOME}/bin/catalina.sh run

Restart=on-failure
RestartSec=10
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tomcat

echo "========================================"
echo "Cloning the application repository"
echo "========================================"

rm -rf "${APP_DIR}"

git clone \
    --branch Master \
    --single-branch \
    https://github.com/abdelrahmanonline4/sourcecodeseniorwr.git \
    "${APP_DIR}"

cd "${APP_DIR}"

if [[ ! -f "${APP_PROPERTIES}" ]]; then
    echo "ERROR: ${APP_PROPERTIES} was not found."
    exit 1
fi

echo "========================================"
echo "Updating database configuration"
echo "========================================"

# The project includes MySQL Connector/J, which supports MariaDB RDS.
sed -i \
    's|^jdbc.driverClassName=.*|jdbc.driverClassName=com.mysql.cj.jdbc.Driver|' \
    "${APP_PROPERTIES}"

sed -i \
    's|^jdbc.url=.*|jdbc.url=jdbc:mysql://vprofile-db.cf5svfyexjcl.us-east-1.rds.amazonaws.com:3306/accounts?useUnicode=true\&characterEncoding=UTF-8\&zeroDateTimeBehavior=CONVERT_TO_NULL|' \
    "${APP_PROPERTIES}"

sed -i \
    's|^jdbc.username=.*|jdbc.username=admin|' \
    "${APP_PROPERTIES}"

sed -i \
    's|^jdbc.password=.*|jdbc.password=admin123|' \
    "${APP_PROPERTIES}"

echo "========================================"
echo "Updating Memcached configuration"
echo "========================================"

sed -i \
    's|^memcached.active.host=.*|memcached.active.host=mc01.vprofile|' \
    "${APP_PROPERTIES}"

sed -i \
    's|^memcached.standBy.host=.*|memcached.standBy.host=mc01.vprofile|' \
    "${APP_PROPERTIES}"

echo "========================================"
echo "Updating RabbitMQ configuration"
echo "========================================"

sed -i \
    's|^rabbitmq.address=.*|rabbitmq.address=rmq01.vprofile|' \
    "${APP_PROPERTIES}"

sed -i \
    's|^rabbitmq.username=.*|rabbitmq.username=rabbitadmin|' \
    "${APP_PROPERTIES}"

sed -i \
    's|^rabbitmq.password=.*|rabbitmq.password=guestvprofile|' \
    "${APP_PROPERTIES}"

echo "========================================"
echo "Showing updated properties"
echo "========================================"

grep -E \
    '^(jdbc|memcached|rabbitmq)\.' \
    "${APP_PROPERTIES}"

echo "========================================"
echo "Building application without tests"
echo "========================================"

mvn clean package -Dmaven.test.skip=true

WAR_FILE="${APP_DIR}/target/vprofile-v2.war"

if [[ ! -f "${WAR_FILE}" ]]; then
    echo "ERROR: WAR file was not created:"
    echo "${WAR_FILE}"
    exit 1
fi

echo "========================================"
echo "Deploying application"
echo "========================================"

systemctl stop tomcat 2>/dev/null || true

rm -rf "${TOMCAT_HOME}/webapps/ROOT"
rm -f "${TOMCAT_HOME}/webapps/ROOT.war"

install \
    -o tomcat \
    -g tomcat \
    -m 0644 \
    "${WAR_FILE}" \
    "${TOMCAT_HOME}/webapps/ROOT.war"

chown -R tomcat:tomcat "${TOMCAT_HOME}"

echo "========================================"
echo "Starting Tomcat"
echo "========================================"

systemctl restart tomcat

sleep 10

if systemctl is-active --quiet tomcat; then
    echo "Tomcat is running successfully."
else
    echo "Tomcat failed to start."
    systemctl status tomcat --no-pager || true
    journalctl -u tomcat --no-pager -n 100 || true
    exit 1
fi

echo "========================================"
echo "Testing Tomcat port 8080"
echo "========================================"

curl -I --max-time 10 http://localhost:8080/ || true

echo "========================================"
echo "Tomcat deployment completed"
echo "========================================"

