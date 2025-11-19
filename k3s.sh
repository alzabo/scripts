# Install specific controller version
env INSTALL_K3S_EXEC="--disable=traefik" INSTALL_K3S_VERSION="v1.33.1+k3s1" sh k3s-install.sh

# Install specific node version
env K3S_URL=https://192.168.1.22:6443 K3S_TOKEN='K1013180b48e5c58265e4XXX.58fr1rbpwpobn16j' INSTALL_K3S_VERSION="v1.33.1+k3s1" sh k3s.sh 
