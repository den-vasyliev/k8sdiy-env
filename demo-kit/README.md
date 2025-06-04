# MCP Demo Kit for kind

This kit provides sample manifests to demonstrate MCP application promotion in a local kind cluster.

## Usage

1. **Create a kind cluster** (if not already done):

   ```sh
   kind create cluster --name ed210-demo
   ```

2. **Apply namespaces:**

   ```sh
   kubectl apply -f namespaces.yaml
   ```

3. **Apply environment config:**

   ```sh
   kubectl apply -f environments.yaml
   ```

4. **Deploy sample applications:**

   ```sh
   kubectl apply -f app-dev.yaml
   kubectl apply -f app-stable.yaml
   kubectl apply -f app-prod.yaml
   ```

5. **Verify:**

   ```sh
   kubectl get application -A
   kubectl get environment
   ```

6. **Use your MCP CLI or server to interact with these resources.**

---

**Note:**  
- Adjust `apiVersion` and `kind` if your CRDs use different group/version.
- You may want to install your CRDs first if not already present:

   ```sh
   kubectl apply -f <path-to-your-crds>
   ```

---

Happy demoing! 