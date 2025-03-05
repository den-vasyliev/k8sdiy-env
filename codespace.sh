#!/bin/bash

# Install Homebrew (OPTIONAL)
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# # Install Terraform, Flux, and htop using Homebrew
## hashicorp/tap/terraform opentofu 
# yes|brew install tenv fluxcd/tap/flux htop kind 



# Install OpenTofu
curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh -s -- --install-method standalone 

# Install K9S to manage the cluster
curl -sS https://webi.sh/k9s | sh
curl -s https://fluxcd.io/install.sh | $(basename "$SHELL")  ## To avoid errors, for bash terminal you may update this line to: curl -s https://fluxcd.io/install.sh | bash 
. <(flux completion $(basename "$SHELL"))   ## To avoid errors, for bash terminal you may update this line to:  . <(flux completion bash)

# Initialize Tofu
cd bootstrap
tofu init

# Prompt the user to enter the GitHub organization
read -p "Enter your GitHub organization: " TF_VAR_github_org

# Prompt the user to enter the GitHub repository
read -p "Enter your GitHub repository: " TF_VAR_github_repository

# Prompt the user to enter the GitHub token securely
read -s -p "Enter your GitHub token: "
echo 

# Export GitHub organization, repository, and token as environment variables
export TF_VAR_github_org="$TF_VAR_github_org"
export TF_VAR_github_repository="$TF_VAR_github_repository"
export TF_VAR_github_token="$TF_VAR_github_token"

# Optionally, you can print the variables to verify (token is hidden)
echo "GitHub Organization: $TF_VAR_github_org"
echo "GitHub Repository: $TF_VAR_github_repository"
echo "GitHub Token: [HIDDEN]"

# Apply terrafrom configuration
tofu apply

# Create alias for k9s, kubectl and command-line autocompletion
alias kk="EDITOR='code --wait' k9s"
alias k=kubectl
# source <(kubectl completion zsh)

# kubectl create secret generic kbot --from-literal=token=$TELE_TOKEN -n app-preview
#
# export ENVOY_SERVICE=$(kubectl get svc -n envoy-gateway-system --selector=gateway.envoyproxy.io/owning-gateway-namespace=default,gateway.envoyproxy.io/owning-gateway-name=eg -o jsonpath='{.items[0].metadata.name}')
#
# kubectl -n envoy-gateway-system port-forward service/${ENVOY_SERVICE} 8888:80 &
#
# k apply -f preview
# flux -n app-preview create secret git github-auth \
#   --url=https://github.com/org/app \
#   --username=flux \
#   --password=${GITHUB_TOKEN}
##
kubectl create secret generic github-auth --from-literal=password=${GITHUB_TOKEN} --from-literal=username=flux -n app-preview
