# junkyard

## Building the junkyard

Local prerequisites:
- `ansible`
- `kubectl`
 
1. Provision a CentOS 8 machine on any platform.
2. Install the required Ansible collection(s) with `ansible-galaxy collection install -r ansible/requirements.yaml`
3. Update the inventory if necessary, and run the `init.yml` playbook `ansible-playbook -i ansible/hosts ansible/init.yml` to install Kubernetes on the machine.
4. Acquire a kubeconfig with the `scripts/k8s-authctl.sh` script. Example: `./scripts/k8s-authctl.sh -iu centos node.example.com user@example`

