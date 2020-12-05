This kustomization is managed by Helm. To rebuild the Helm chart:
1. Clone https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner
2. Run `helm template --values helm-values.yaml junkyard <path to cloned repo>/helm/provisioner > helm-generated.yaml
