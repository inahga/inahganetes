# inahganetes

Kubernetes the hard way.

## Building inahganetes

Local prerequisites:
- `ansible`
- `kubectl`
 
1. Install the required Ansible collection(s) with `ansible-galaxy collection install -r ansible/requirements.yaml`
1. Provision a CentOS 8 machine on any platform. If your provisioner does not set sane defaults (i.e. SSH public key auth), then use `ansible-playbook -i ansible/hosts ansible/init.yml --ask-pass` to do this for you.
1. Update the inventory if necessary, and run the playbook `ansible-playbook -i ansible/hosts ansible/init-k8s.yml` to install Kubernetes on the machine.
1. Acquire a kubeconfig with the `scripts/k8s-authctl.sh` script. Example: `./scripts/k8s-authctl.sh -iu centos node.example.com user@example`.
1. Apply base resources with `kustomize build kubernetes/overlays/base | kubectl apply -f -`. Wait a few moments to allow webhooks and controllers to register themselves.
1. Apply the rest of the configuration with `kustomize build kubernetes/overlays/junkyard | kubectl apply -f -`.

## Secrets
### AWS Route 53
`cert-manager` provisions a wildcard Let's Encrypt certificate using the DNS01 challenge method.
A Route53 API token access token must be provided for this to be done.
In `inahgaform` repo, a user is already set up for this, `certman`.
If required, create a secret key for this user with `aws iam create-access-key --user-name certman`.
