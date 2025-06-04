
helm install --namespace cert-manager cert-manager-webhook-namecom  ./deploy/cert-manager-webhook-namecom/
kubectl create secret generic namedotcom-credentials --from-literal=api-token= --namespace cert-manager 

kubectl create secret generic namedotcom-credentials --from-literal=api-token=<apikey> --namespace cert-manager 


kubectl apply -f- <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-namecom
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: den.vasyliev@gmail.com
    privateKeySecretRef:
      name: letsencrypt-account-key
    solvers:
    - dns01:
        webhook:
          groupName: acme.name.com
          solverName: namedotcom
          config:
            username: den.vasyliev@gmail.com
            apitokensecret:
              name: namedotcom-credentials
              key: api-token
EOF


kubectl apply -f- <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: wildcard-mockee-me
  namespace: kgateway-system 
spec:
  secretName: wildcard-mockee-me-tls
  issuerRef:
    name: letsencrypt-namecom
    kind: ClusterIssuer
  commonName: "*.mockee.me"
  dnsNames:
    - "*.mockee.me"
    - "mockee.me"
EOF


kubectl apply -f- <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cert-manager-webhook-namecom:solver
rules:
  - apiGroups: ["acme.mycompany.com"]
    resources: ["namecom"]
    verbs: ["create", "get", "list", "watch", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cert-manager-webhook-namecom:solver
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager-webhook-namecom:solver
subjects:
  - kind: ServiceAccount
    name: cert-manager
    namespace: cert-manager
---
EOF


kubectl apply -f- <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: agent-tls
  namespace: kagent
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  tls:
    - hosts:
        - "*.mockee.me"
      secretName: wildcard-mockee-me-tls
  rules:
    - host: agent.mockee.me
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kagent
                port:
                  number: 80
EOF

kubectl apply -f- <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: a2a-tls
  namespace: kagent
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  tls:
    - hosts:
        - "*.mockee.me"
      secretName: wildcard-mockee-me-tls
  rules:
    - host: a2a.mockee.me
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kagent
                port:
                  number: 80
EOF

kubectl apply -f- <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: agent-tls
  namespace: ed210
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  tls:
    - hosts:
        - "*.mockee.me"
      secretName: wildcard-mockee-me-tls
  rules:
    - host: ed210.mockee.me
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ed210
                port:
                  number: 8080
EOF

kubectl apply -f- <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mcp-tls
  namespace: ed210
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  tls:
    - hosts:
        - "*.mockee.me"
      secretName: wildcard-mockee-me-tls
  rules:
    - host: mcp.mockee.me
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ed210-mcp
                port:
                  number: 8090
EOF

kubectl apply -f- <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mcp-tls
  namespace: ed210
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  tls:
    - hosts:
        - "*.mockee.me"
      secretName: wildcard-mockee-me-tls
  rules:
    - host: mcp.mockee.me
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ed210-mcp
                port:
                  number: 8090
EOF
