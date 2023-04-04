1. Initial setup of nodes the following script needs to be executed on every node, with 2 arguments: user which will be added to the system and ssh public key which will be added to this user.
example: `./setup.sh tester 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkXQjgfbyw++mAC5QhX3ToFsJgWAzbDFDAS1jzwRkE0ortyX7LhAOAY76YXsL+fNOoa/KkCRABMdwvTnuAtJ59lCV/QY3TlxXymbENZ7pOLjGcbozWvzUsoyyyns/e9WJxh8Gf36FFxNtTyyaa0Nq2+NPhDu5+m0yKrs3t65eL+H8b3ZJIbjXkq7iQvgrZovSJK3RW+FvP75muquTc/RXyvVFZ2HGpek2nP7rzsu18hUqspjGzeNG5xKmJZNYP2f9sNKVSyHi3KId8sWeSkjWHFM9QnxbOHYuQN86w62LJp7VV+V8hv21DWn3GA/d4U/FZh9NdNctxzJrWMsrjZLdQ+d1jbhiAd/M1JohNnmfm8R1t8BgSHyoQP1F9Sk0vXp8ma4japVb+Txtkw5A9BWO2TWddGEGH0onli0eXqgv8Ab0N27BkBpRhjCbc9my2YzzDlHHIXk1A0/hey+NxP1msJxoyOn2zRtZV1Pch8O2YWjI2h45UJ4DoOYdbpZzd1Kc='`
After it finishes doublecheck that swap is disabled and the new user is created and the public ssh key added.
```
#!/bin/bash


USER=${1}
PUBKEY=${2}
DOCKER_VERSION="5:20.10.23~3-0~ubuntu-jammy"


if [ $# -ne 2 ];then
        echo "Please provide 2 arguments: username ssh_public_key"
        exit 0
fi

if [ -z ${USER} ] || [ -z ${PUBKEY} ];then
        echo "Please provide a valid username and public key"
        exit 0
fi

## setup sysctl
echo "Setting up sysctl settings"
cat > /etc/sysctl.d/11-k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.conf.all.forwarding = 1
EOF
sysctl --system

## update the repositories and install docker
echo "Updating packages and installing docker-ce"
apt-get update; apt-get install ca-certificates curl gnupg -y
mkdir -m 0755 -pv /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update; apt-get install docker-ce=${DOCKER_VERSION} docker-ce-cli=${DOCKER_VERSION} containerd.io docker-buildx-plugin docker-compose-plugin -y

## Adding user which will be used to bootstrap the cluster
useradd ${USER} -s /bin/bash --create-home -G docker
echo "${USER}:6bg7Q2CdxdNTBjKpYnux" | chpasswd
mkdir -pv /home/${USER}/.ssh
echo "${PUBKEY}" > /home/${USER}/.ssh/authorized_keys

## Disable swap
echo "Disabling swap"
cp /etc/fstab /etc/fstab.backup
sed -i '/swap.img/d' /etc/fstab
swapoff -a
```

2. Download [RKE](https://github.com/rancher/rke/releases/tag/v1.4.3) binary
```
wget https://github.com/rancher/rke/releases/download/v1.4.3/rke_linux-amd64 && mv rke_linux-amd64 /usr/local/bin/rke && chmod +x /usr/local/bin/rke && rke --help
```

3. Save the following content to cluster.yml, the kubernetes cluster will be deployed with this options, more information on the available configuration can be found [here](https://rke.docs.rancher.com/config-options).
```
nodes:
    - address: 192.168.100.147  ### IP address of the master
      user: tester              ### SSH Username
      role:
        - controlplane
        - etcd
      port: 22
      docker_socket: /var/run/docker.sock
    ### Worker nodes definitions, if there are more than 1 to be added like the following.
    - address: 192.168.100.148 ### IP of the worker
      user: tester             ### SSH Username
      role:
        - worker
      port: 22
      labels:
        app: ingress

ignore_docker_version: true
enable_cri_dockerd: true

#### Path to SSH key for bootstraping the cluster
ssh_key_path: /root/.ssh/id_rsa

#### Kubernetes cluster name
cluster_name: tester

kubernetes_version: v1.23.16-rancher2-1


services:
    etcd:
      uid: 52034
      gid: 52034
    kube-api:
      service_cluster_ip_range: 10.43.0.0/16
      service_node_port_range: 30000-32767
      pod_security_policy: false
      secrets_encryption_config:
        enabled: true
        custom_config:
          apiVersion: apiserver.config.k8s.io/v1
          kind: EncryptionConfiguration
          resources:
          - resources:
            - secrets
            providers:
            - aescbc:
                keys:
                - name: k-fw5hn
                  secret: RTczRjFDODMwQzAyMDVBREU4NDJBMUZFNDhCNzM5N0I=
            - identity: {}
      audit_log:
        enabled: false
      event_rate_limit:
        enabled: false
      always_pull_images: false
    kube-controller:
      cluster_cidr: 10.42.0.0/16
      service_cluster_ip_range: 10.43.0.0/16
      extra_args:
        v: 4
        feature-gates: RotateKubeletServerCertificate=true
        cluster-signing-cert-file: "/etc/kubernetes/ssl/kube-ca.pem"
        cluster-signing-key-file: "/etc/kubernetes/ssl/kube-ca-key.pem"
    kubelet:
      cluster_domain: cluster.local
      cluster_dns_server: 10.43.0.10
      fail_swap_on: true
      pod-infra-container-image: "k8s.gcr.io/pause:3.2"
      generate_serving_certificate: true
      extra_args:
        max-pods: 110
        feature-gates: RotateKubeletServerCertificate=true
      extra_binds:
        - "/usr/libexec/kubernetes/kubelet-plugins:/usr/libexec/kubernetes/kubelet-plugins"
    scheduler:
      extra_args:
        # Set the level of log output to debug-level
        v: 4
    kubeproxy:
      extra_args:
        # Set the level of log output to debug-level
        v: 4

authorization:
    mode: rbac

addon_job_timeout: 120

network:
  plugin: canal
  # Specify MTU
  mtu: 1400
  options:
    # Configure interface to use for Canal
    canal_iface: enp0s3                      #### Needs to match the host's primary interface
    canal_flannel_backend_type: vxlan
    # Available as of v1.2.6
    canal_autoscaler_priority_class_name: system-cluster-critical
    canal_priority_class_name: system-cluster-critical
  # Available as of v1.2.4
  tolerations:
  - key: "node.kubernetes.io/unreachable"
    operator: "Exists"
    effect: "NoExecute"
    tolerationseconds: 300
  - key: "node.kubernetes.io/not-ready"
    operator: "Exists"
    effect: "NoExecute"
    tolerationseconds: 300
  # Available as of v1.1.0
  update_strategy:
    strategy: RollingUpdate
    rollingUpdate:
      maxUnavailable: 6

# Specify DNS provider (coredns or kube-dns)
dns:
  provider: coredns
  # Available as of v1.1.0
  update_strategy:
    strategy: RollingUpdate
    rollingUpdate:
      maxUnavailable: 20%
      maxSurge: 15%
  linear_autoscaler_params:
    cores_per_replica: 0.34
    nodes_per_replica: 4
    prevent_single_point_failure: true
    min: 2
    max: 3

# Specify monitoring provider (metrics-server)
monitoring:
  provider: metrics-server
  # Available as of v1.1.0
  update_strategy:
    strategy: RollingUpdate
    rollingUpdate:
      maxUnavailable: 8

# Currently only nginx ingress provider is supported.
# To disable ingress controller, set `provider: none`
# `node_selector` controls ingress placement and is optional
ingress:
  provider: nginx
  node_selector:
    app: ingress
  network_mode: hostPort
  http_port: 80
  https_port: 443
  extra_args:
    http-port: 80
    https-port: 443
  # Available as of v1.1.0
  update_strategy:
    strategy: RollingUpdate
    rollingUpdate:
      maxUnavailable: 5

```

4. Install kubectl
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && mv kubectl /usr/local/bin/ && chmod +x /usr/local/bin/kubectl
```

5. Setup kubernetes authentication
```
mkdir ~/.kube
mv kube_config_cluster.yml ~/.kube/config
kubectl get nodes
```

6. Optional install helm and kube prometheus stack, more information [here](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack).
```
## Install helm
wget https://get.helm.sh/helm-v3.11.2-linux-amd64.tar.gz
tar -xzf helm-v3.11.2-linux-amd64.tar.gz --strip-components 1
mv helm /usr/local/bin/helm
helm --version

## Add kube prometheus stack helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

## Install the chart in the namespace monitoring
helm install monitoring-stack prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```
After the installation is complete, you can check the monitoring namespace and make sure that all resources are created.
Grafana can be exposed trough several methods:
1. Using kubectl port-forward if the service is of type: clusterIP
2. Modify the service and change the type to NodePort, then it can be accessed on any node IP and the coresponding node port
3. Modify the chart's values.yaml and create ingress resource for grafana, after this is done it can be accessed with the domain name specified and the node port of ingress-nginx
