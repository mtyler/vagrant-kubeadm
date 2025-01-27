#!/bin/sh

DOMAIN="k8s.local"
GROUP="minio-user"
USER="minio-user"
CERT_DIR="/home/minio-user/.minio/certs"
CA_KEY="${CERT_DIR}/CAs/ca.key"
CA_CERT="${CERT_DIR}/CAs/ca.crt"
SERVER_KEY="${CERT_DIR}/server.key"
SERVER_CSR="${CERT_DIR}/server.csr"
SERVER_CERT="${CERT_DIR}/server.crt"
# Create the group if it doesn't exist
sudo groupadd -r "$GROUP"
# Create the user with the specified group and home directory
sudo useradd -m -r -g "$GROUP" "$USER"
#operation not permitted error thrown when trying to run chown
#sudo chown minio-user:minio-user /mnt/disk1 /mnt/disk2 /mnt/disk3 /mnt/disk4

#### Create certificate directory if it doesn't exist
###mkdir -p "${CERT_DIR}"
###mkdir -p "${CERT_DIR}/CAs"
###
#### Generate CA private key
###openssl genpkey -algorithm RSA -out "${CA_KEY}" -pkeyopt rsa_keygen_bits:2048
###
#### Generate CA certificate
###openssl req -x509 -new -nodes -key "${CA_KEY}" -sha256 -days 365 -out "${CA_CERT}" -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=${DOMAIN}"
###
#### Generate server private key
###openssl genpkey -algorithm RSA -out "${SERVER_KEY}" -pkeyopt rsa_keygen_bits:2048
###
#### Generate server certificate signing request (CSR)
###openssl req -new -key "${SERVER_KEY}" -out "${SERVER_CSR}" -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=${DOMAIN}"
###
#### Generate server certificate signed by the CA
###openssl x509 -req -in "${SERVER_CSR}" -CA "${CA_CERT}" -CAkey "${CA_KEY}" -CAcreateserial -out "${SERVER_CERT}" -days 365 -sha256
###
#### Output the generated files
###echo "Generated the following files in ${CERT_DIR}:"
###echo "CA Key: ${CA_KEY}"
###echo "CA Certificate: ${CA_CERT}"
###echo "Server Key: ${SERVER_KEY}"
###echo "Server CSR: ${SERVER_CSR}"
###echo "Server Certificate: ${SERVER_CERT}"

wget -q https://dl.min.io/server/minio/release/linux-arm64/archive/minio_20241218131544.0.0_arm64.deb -O minio.deb
sudo dpkg -i minio.deb

if [ ! -f '/usr/lib/systemd/system/minio.service' ]; then
  echo "file not found"
  exit
fi

cat <<EOF | sudo tee /etc/default/minio
# Set the hosts and volumes MinIO uses at startup
# The command uses MinIO expansion notation {x...y} to denote a
# sequential series.
#
# The following example covers four MinIO hosts
# with 4 drives each at the specified hostname and drive locations.
# The command includes the port that each MinIO server listens on
# (default 9000)

## TLS 
#MINIO_VOLUMES="https://cp{1...3}.${DOMAIN}:9000/mnt/disk{1...4}/minio"

## cp1, cp2, cp3
MINIO_VOLUMES="http://cp{1...3}.${DOMAIN}:9000/mnt/disk{1...4}/minio"

## single node cp2
#MINIO_VOLUMES="http://cp2.${DOMAIN}:9000/mnt/disk{1...4}/minio"

# Set all MinIO server options
#
# The following explicitly sets the MinIO Console listen address to
# port 9001 on all network interfaces. The default behavior is dynamic
# port selection.

MINIO_OPTS="--console-address :9001"

# Set the root username. This user has unrestricted permissions to
# perform S3 and administrative API operations on any resource in the
# deployment.
#
# Defer to your organizations requirements for superadmin user name.

MINIO_ROOT_USER=minioadmin

# Set the root password
#
# Use a long, random, unique string that meets your organizations
# requirements for passwords.

MINIO_ROOT_PASSWORD=minio-password
EOF

cat << EOF | sudo tee /usr/lib/systemd/system/minio.service
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
Type=notify

WorkingDirectory=/usr/local

# using vagrant instead of minio-user because the shared folders 
# are created by vagrant and ownership is not changeable
User=vagrant
Group=vagrant
ProtectProc=invisible

EnvironmentFile=-/etc/default/minio
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=1048576

# Turn-off memory accounting by systemd, which is buggy.
MemoryAccounting=no

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutSec=infinity

SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start minio.service
sudo systemctl enable minio.service