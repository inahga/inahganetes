# junkyard

## Building the junkyard

Local prerequisites:
- `ansible`
- `kubectl`
 
1. Install the required Ansible collection(s) with `ansible-galaxy collection install -r ansible/requirements.yaml`
1. Provision a CentOS 8 machine on any platform. If your provisioner does not set sane defaults (i.e. SSH public key auth), then use `ansible-playbook -i ansible/hosts ansible/init.yml --ask-pass` to do this for you.
1. Update the inventory if necessary, and run the playbook `ansible-playbook -i ansible/hosts ansible/init-k8s.yml` to install Kubernetes on the machine.
1. Acquire a kubeconfig with the `scripts/k8s-authctl.sh` script. Example: `./scripts/k8s-authctl.sh -iu centos node.example.com user@example`.

