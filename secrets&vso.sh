## Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

## Install kube-ps1
brew install kube-ps1

## Install gcloud cli
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
tar -xf google-cloud-cli-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
./google-cloud-sdk/bin/gcloud init
gcloud auth application-default login
gcloud components install gke-gcloud-auth-plugin
export PATH="$(pwd)/google-cloud-sdk/bin:$PATH"

## Install Elastic Cloud on Kubernetes (ECK) operator
kubectl create -f https://download.elastic.co/downloads/eck/2.16.1/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.16.1/operator.yaml
kubectl -n elastic-system logs statefulset.apps/elastic-operator --tail 5

## Deploy Elasticsearch cluster
cat <<EOF | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
spec:
  version: 8.17.2
  nodeSets:
  - name: default
    count: 1
    config:
      node.store.allow_mmap: false
EOF

## Check Elasticsearch status and get service details
kubectl get elastic
kubectl get service quickstart-es-http

## Retrieve Elasticsearch password and access the cluster
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
kubectl port-forward service/quickstart-es-http 9200&
curl -u "elastic:$PASSWORD" -k "https://localhost:9200"

## Deploy Kibana
cat <<EOF | kubectl apply -f -
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: quickstart
spec:
  version: 8.17.3
  count: 1
  elasticsearchRef:
    name: quickstart
EOF

## Expose Kibana service
kubectl get kibana
kubectl expose deployment quickstart-kb --port 443 --target-port 5601 --type LoadBalancer
kubectl get secret quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo

## Add HashiCorp Helm repository and update
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm search repo hashicorp/vault

## Create values.yaml for Vault Helm chart configuration
cat <<EOF > values.yaml
server:
  dev:
    enabled: true
    devRootToken: "root"
  logLevel: debug
  service:
    enabled: true
    type: ClusterIP
    port: 8200
    targetPort: 8200
ui:
  enabled: true
  serviceType: "LoadBalancer"
  externalPort: 8200
injector:
  enabled: "false"
EOF

## Install Vault using Helm
helm install vault hashicorp/vault -n vault --create-namespace --values values.yaml

## Access Vault pod and configure authentication and secrets
kubectl exec -it vault-0 -n vault -- /bin/sh
vault auth enable -path demo-auth-mount kubernetes
vault write auth/demo-auth-mount/config \
   kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"
vault secrets enable -path=kvv2 kv-v2

## Create policy for webapp
cd tmp
tee app.json <<EOF
path "kvv2/data/app/config" {
   capabilities = ["read", "list"]
}
EOF
vault policy write app app.json

## Create role for Kubernetes authentication
vault write auth/demo-auth-mount/role/role1 \
   bound_service_account_names=demo-static-app \
   bound_service_account_namespaces=app \
   policies=app \
   audience=vault \
   ttl=24h

## Store static secrets in Vault
vault kv put kvv2/app/config username="static-user" password="static-password"
exit

## Create values file for Vault Secrets Operator
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

## Install Vault Secrets Operator using Helm
helm install vault-secrets-operator hashicorp/vault-secrets-operator -n vault-secrets-operator-system --create-namespace --values vault-operator-values.yaml

## Create namespace for the application
kubectl create ns app

## Create Vault authentication configuration for static secrets
kubectl apply -f - <<"EOF"
apiVersion: v1
kind: ServiceAccount
metadata:
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

## Create static secret configuration
kubectl apply -f - <<EOF
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: vault-kv-app
  namespace: app
spec:
  type: kv-v2
  mount: kvv2
  path: app/config
  destination:
    name: secretkv
    create: true
  refreshAfter: 30s
  vaultAuthRef: static-auth
EOF

## Verify the secret is created
kubectl get secrets -n app

## Update static secrets in Vault
kubectl exec --stdin=true --tty=true vault-0 -n vault -- /bin/sh
vault kv put kvv2/webapp/config username="static-user2" password="static-password2"
kubectl -n vault exec -it vault-0 -- vault token create

## Apply gatewayapi and preview configurations
kubectl apply -f gatewayapi
kubectl apply -f preview

## Create GitHub authentication secrets
kubectl create secret generic github-auth --from-literal=password=${GITHUB_TOKEN} --from-literal=username=flux -n flux-system
kubectl create secret generic github-auth --from-literal=password=${GITHUB_TOKEN} --from-literal=username=flux -n app-preview
