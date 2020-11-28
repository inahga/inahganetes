#!/bin/bash
set -euo pipefail

USAGE="
Usage: $0 [-c CLUSTERROLE] [-hir] [-u USERNAME] SERVER CLIENT_NAME
Connect to SERVER and generate an administrative kubeconfig, using CLIENT_NAME
as the principal. This is performed as root on the remote server, so it works
if you don't currently have a kubectl context.

Options:
    -c          Select the ClusterRole to bind to (default: cluster-admin)
    -h          Print this help message.
    -i          Install the kubeconfig to your home directory.
    -r          Revoke the permissions on CLIENT_NAME rather than generating a
                new kubeconfig.
    -u USERNAME Connect to the target server with a different username. (default:
                root).

When using -r, the ClusterRoleBinding that grants permissions on the CLIENT_NAME
certificate is deleted. Kubernetes does not have a means of managing certificate
revocation. This means that an adversary in possession of a compromised cert can
still authenticate to the server, but they will not be able to do anything."

if ! [ -x "$(command -v kubectl)" ]; then
	echo "kubectl is missing from the local machine"
	exit 1
fi

CLUSTERROLE=cluster-admin
REVOKE=
USERNAME=root
INSTALL=
while getopts "c:hiru:" OPT; do
	case $OPT in
	c)
		CLUSTERROLE=$OPTARG
		;;
	i)
		INSTALL=1
		;;
	r)
		REVOKE=1
		;;
	u)
		USERNAME=$OPTARG
		;;
	h)
		echo "$USAGE"
		exit 0
		;;
	\?)
		echo "Invalid option: $OPTARG"
		echo "$USAGE"
		exit 1
		;;
	:)
		echo "Option $OPTARG requires an argument."
		echo "$USAGE"
		exit 1
		;;
	esac
done

shift "$((OPTIND - 1))"
if [ -z "${1+x}" ]; then
	echo "Must specify the server address."
	echo "$USAGE"
	exit 1
elif [ -z "${2+x}" ]; then
	echo "Must specify a name."
	echo "$USAGE"
	exit 1
fi

SERVER=$1
CLIENT_NAME=$2

check_server() {
	ssh -o ConnectTimeout=10 "$USERNAME@$SERVER" echo 1>/dev/null
}

remote_exec() {
	# shellcheck disable=SC2029
	ssh "$USERNAME@$SERVER" "$@"
}

create() {
	# shellcheck disable=SC2029
	KUBECONFIG=$(remote_exec "sudo kubeadm alpha kubeconfig user --client-name $CLIENT_NAME 2>/dev/null")

	remote_exec "KUBECONFIG=/etc/kubernetes/admin.conf sudo -E kubectl create clusterrolebinding $CLIENT_NAME --clusterrole=$CLUSTERROLE --user=$CLIENT_NAME" 1>&2

	if [ -n "$INSTALL" ]; then
		if [ -e ~/.kube/config ]; then
			TEMP=$(mktemp)
			trap 'rm $TEMP' EXIT
			echo "$KUBECONFIG" >"$TEMP"
			MERGED=$(KUBECONFIG="$TEMP:$HOME/.kube/config" kubectl config view --flatten)
			echo "$MERGED" >~/.kube/config
		else
			mkdir -p ~/.kube
			echo "$KUBECONFIG" >~/.kube/config
		fi
	else
		echo "$KUBECONFIG"
	fi
}

revoke() {
	remote_exec "KUBECONFIG=/etc/kubernetes/admin.conf sudo -E kubectl delete clusterrolebinding $CLIENT_NAME" 1>&2
}

check_server
if [ -n "$REVOKE" ]; then
	revoke
else
	create
fi
