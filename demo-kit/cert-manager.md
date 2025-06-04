# Manual: Setting up cert-manager with Name.com DNS-01 for Wildcard TLS on Kubernetes

## 1. Install cert-manager

```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

## 2. Create Name.com API Credentials

```sh
kubectl create secret generic namedotcom-credentials \
  --from-literal=api-token=<YOUR_NAMECOM_API_TOKEN> \
  --namespace cert-manager
```

Or, as a Kubernetes Secret manifest:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: namecom-api-key
  namespace: cert-manager
type: Opaque
stringData:
  username: "<YOUR_NAMECOM_USERNAME>"
  token: "<YOUR_NAMECOM_API_TOKEN>"
```
Apply with:
```sh
kubectl apply -f <filename>.yaml
```

## 3. Deploy the Name.com DNS-01 Webhook

Clone and install the webhook:

```sh
git clone https://github.com/imgrant/cert-manager-webhook-namecom
cd cert-manager-webhook-namecom
helm install --namespace cert-manager cert-manager-webhook-namecom ./deploy/cert-manager-webhook-namecom/
```

## 4. Create ClusterIssuer for Let's Encrypt DNS-01

Example manifest (update secrets as needed):

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns
spec:
  acme:
    email: <YOUR_EMAIL>
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-dns
    solvers:
      - dns01:
          webhook:
            groupName: acme.mycompany.com
            solverName: namecom
            config:
              usernameSecretRef:
                name: namecom-api-key
                key: username
              tokenSecretRef:
                name: namecom-api-key
                key: token
```
Apply with:
```sh
kubectl apply -f <filename>.yaml
```

## 5. Issue a Wildcard Certificate

Example manifest:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: wildcard-mockee-me
  namespace: default
spec:
  secretName: wildcard-mockee-me-tls
  issuerRef:
    name: letsencrypt-dns
    kind: ClusterIssuer
  commonName: "*.mockee.me"
  dnsNames:
    - "*.mockee.me"
    - "mockee.me"
```
Apply with:
```sh
kubectl apply -f <filename>.yaml
```

## 6. Copy TLS Secret to Other Namespaces (if needed)

To use the certificate in another namespace (e.g., cert-manager or kgateway-system):

```sh
kubectl get secret wildcard-mockee-me-tls -n default -o yaml \
  | sed '/namespace:/d;/resourceVersion:/d;/uid:/d;/creationTimestamp:/d;/selfLink:/d;/ownerReferences:/d' \
  | kubectl apply -n cert-manager -f -
```
Repeat for other namespaces as needed.

## 7. Create Gateway Resource for HTTPS

Example manifest for Gateway API:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: agent-https-gateway
  namespace: kgateway-system
  labels:
    gateway: https
spec:
  gatewayClassName: kgateway
  listeners:
    - name: https
      port: 443
      protocol: HTTPS
      hostname: "*.mockee.me"
      tls:
        mode: Terminate
        certificateRefs:
          - name: wildcard-mockee-me
            kind: Secret
      allowedRoutes:
        namespaces:
          from: All
```
Apply with:
```sh
kubectl apply -f <filename>.yaml
```

---

## Notes

- Replace placeholders like `<YOUR_NAMECOM_API_TOKEN>`, `<YOUR_NAMECOM_USERNAME>`, and `<YOUR_EMAIL>` with your actual values.
- Ensure all referenced secrets exist in the correct namespaces.
- For troubleshooting, check cert-manager and webhook pod logs. 
