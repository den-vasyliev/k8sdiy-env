# Install K9S to manage the cluster
curl -sS https://webi.sh/k9s | sh

# Create alias for k9s, kubectl and command-line autocompletion
alias kk="EDITOR='code --wait' k9s"
alias k=kubectl

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind create cluster

# kubelet rotation

# Add HashiCorp Helm repository and update
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm search repo hashicorp/vault

# Create values.yaml for Vault Helm chart configuration
cat <<EOF > values.yaml
server:
  dev:
    enabled: true
    devRootToken: "root"
  logLevel: debug
  service:
    enabled: true
    type: ClusterIP
    # Port on which Vault server is listening
    port: 8200
    # Target port to which the service should be mapped to
    targetPort: 8200
ui:
  enabled: true
  serviceType: "LoadBalancer"
  externalPort: 8200

injector:
  enabled: "false"
EOF

# Install Vault using Helm
helm install vault hashicorp/vault -n vault --create-namespace --values values.yaml

# Access Vault pod and configure authentication and secrets
kubectl exec --stdin=true --tty=true vault-0 -n vault -- /bin/sh
vault auth enable -path demo-auth-mount kubernetes
vault write auth/demo-auth-mount/config \
   kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"
vault secrets enable -path=kvv2 kv-v2

# Create policy for webapp
cd tmp
tee webapp.json <<EOF
path "kvv2/data/webapp/config" {
   capabilities = ["read", "list"]
}
EOF
vault policy write webapp webapp.json

# Create role for Kubernetes authentication
vault write auth/demo-auth-mount/role/role1 \
   bound_service_account_names=demo-static-app \
   bound_service_account_namespaces=app \
   policies=webapp \
   audience=vault \
   ttl=24h

# Store static secrets in Vault
vault kv put kvv2/webapp/config username="static-user" password="static-password"
exit

# Create values file for Vault Secrets Operator
cat <<EOF > vault-operator-values.yaml
defaultVaultConnection:
  enabled: true
  address: "http://vault.vault.svc.cluster.local:8200"
  skipTLSVerify: false
controller:
  manager:
    clientCache:
      persistenceModel: direct-encrypted
      storageEncryption:
        enabled: true
        mount: demo-auth-mount
        keyName: vso-client-cache
        transitMount: demo-transit
        kubernetes:
          role: auth-role-operator
          serviceAccount: vault-secrets-operator-controller-manager
          tokenAudiences: ["vault"]
EOF

# Install Vault Secrets Operator using Helm
helm install vault-secrets-operator hashicorp/vault-secrets-operator -n vault-secrets-operator-system --create-namespace --values vault-operator-values.yaml

# Create namespace for the application
kubectl create ns app

# Create Vault authentication configuration for static secrets
cat <<EOF > vault-auth-static.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  # SA bound to the VSO namespace for transit engine auth
  namespace: vault-secrets-operator-system
  name: demo-operator
---
apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: app
  name: demo-static-app
---
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
  name: static-auth
  namespace: app
spec:
  method: kubernetes
  mount: demo-auth-mount
  kubernetes:
    role: role1
    serviceAccount: demo-static-app
    audiences:
      - vault
EOF

# Apply Vault authentication configuration
kubectl apply -f vault-auth-static.yaml

# Create static secret configuration
cat <<EOF > static-secret.yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: vault-kv-app
  namespace: app
spec:
  type: kv-v2

  # mount path
  mount: kvv2

  # path of the secret
  path: webapp/config

  # dest k8s secret
  destination:
    name: secretkv
    create: true

  # static secret refresh interval
  refreshAfter: 30s

  # Name of the CRD to authenticate to Vault
  vaultAuthRef: static-auth
EOF

# Apply static secret configuration
kubectl apply -f static-secret.yaml

# Verify the secret is created
k get secrets -n app

# Update static secrets in Vault
kubectl exec --stdin=true --tty=true vault-0 -n vault -- /bin/sh
vault kv put kvv2/webapp/config username="static-user2" password="static-password2"