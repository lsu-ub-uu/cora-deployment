#!/bin/bash
MINIKUBE_MOUNT="/tmp/minikube-mount/"
CPUS="12"
MEMORY="16096"
HELM_REPO="epc"
HELM_REPO_URL="https://helm.epc.ub.uu.se/"
VALID_SYSTEMS=("systemone" "diva" "alvin")
UNINSTALL="false"
NO_CACHE="false"
FRESH="false"
CHART_LOCATION="helm"
NAMESPACE=""

start_minikube() {
    verify_system_selection
    prepare_for_installation
    delete_old_installation
    install_new_helm_chart
    print_step "Installation finished!"
    print_deployment_access
}

uninstall_release() {
    print_step "Trying to uninstall helm release ($RELEASE_NAME) within NS $NAMESPACE."
    verify_system_selection
    delete_old_installation
    print_step "System uninstalled!"
}

cleanup_failure() {
    print_step "Clean up initialized..."
    print_step "Waiting for any created pods to terminate"
    kubectl wait --for=delete pod --all --namespace="$NAMESPACE" --timeout 300s
    delete_old_installation
    print_step "Clean up complete..."
    exit 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

print_usage() {
    print_step "Usage: $(basename "$0") <system> [OPTIONS]"
    echo "Systems:"
    echo "   ${VALID_SYSTEMS[*]}"
    echo ""
    echo "Options:"
    echo "  --uninstall, -rm    Uninstall the specified system"
    echo "  --nocache, -nc      Prune all docker images inside minikube"
    echo "  --fresh, -new       Delete existing minikube and create new for a clean install"
    exit 1
}

script_setup() {
    cd $CHART_LOCATION

    if [[ $# -lt 1 ]]; then
        print_usage
    fi

    NAMESPACE="$1"
    RELEASE_NAME="$NAMESPACE-minikube"
    shift 1

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --uninstall|-rm)
                UNINSTALL="true"
                shift
                ;;
             --nocache|-nc)
                NO_CACHE="true"
                shift
                ;;
             --fresh|-new)
                FRESH="true"
                shift
                ;; 
            *)
                print_usage
                ;;
        esac
    done
}

verify_system_selection() {
    if [[ -z "$NAMESPACE" ]]; then
    print_warning "Error: --system argument is required. Allowed values are: ${VALID_SYSTEMS[*]}"
    exit 1
    fi

    if [[ ! " ${VALID_SYSTEMS[*]} " =~ " $NAMESPACE " ]]; then
        print_warning "Error: Invalid system '$NAMESPACE'. Allowed values are: ${VALID_SYSTEMS[*]}"
        exit 1
    fi
}

prepare_for_installation() {
     if [[ "$FRESH" == "true" ]]; then
        print_step "Deleting existing minikube setup for a clean install..."
        minikube delete
    fi

    print_deployment_info

    # Start minikube
    if ! minikube status | grep -q "Running"; then
        print_step "Minikube is not running. Starting Minikube..."
        minikube start --memory $MEMORY --cpus $CPUS --mount --mount-string "$MINIKUBE_MOUNT:/mnt/minikube"
        until minikube status | grep -q "Running"; do sleepy "waiting for minikube status Running..." 3; done

        print_step "Waiting for all kube-system pods to be running before proceeding..."
        kubectl wait --for=condition=Ready pod --all --namespace="kube-system" --timeout=300s

        # Increase inotify limits in Minikube
        print_step "Increasing inotify limits inside minikube..."
        minikube ssh -- "sudo sysctl -w fs.inotify.max_user_instances=1024"
        minikube ssh -- "sudo sysctl -w fs.inotify.max_user_watches=524288"
    fi

    # Prune docker images / clear image cache
    if [[ "$NO_CACHE" == "true" ]]; then
        print_step "Pruning cached docker images..."
        minikube ssh -- docker system prune --all --force
    fi
}

delete_old_installation() {
    print_step "Deleting and cleaning up old installation..."

    # Uninstall old release
    existing_release=$(helm list -o json --namespace $NAMESPACE | jq -r '.[0].name')
    if [[ -n "$existing_release" && "$existing_release" != "null" ]]; then
        print_step "Uninstalling old release ($existing_release)..."
        helm uninstall "$existing_release" -n "$NAMESPACE"
    else
        print_warning "Could not find an earlier release to uninstall..."
    fi

    # Delete namespace
    if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        print_step "Deleting existing namespace '$NAMESPACE'..."
        kubectl delete namespace "$NAMESPACE"
    else
        print_warning "Namespace '$NAMESPACE' does not exist, skipping deletion."
    fi

    # Delete persistent volumes
    existing_persistent_volumes=$(kubectl get pv -o name | grep "^persistentvolume/$NAMESPACE")
    if [[ -n "$existing_persistent_volumes" ]]; then
        print_step "Deleting Persistent Volumes..."
        kubectl delete $existing_persistent_volumes
    else
        print_warning "No persistent volumes to delete for namespace '$NAMESPACE'."
    fi

    # Cleanse mounts
    print_step "Cleansing any mounted data..."
    minikube ssh -- "sudo rm -rf /mnt/minikube/$NAMESPACE/*"
    print_step "Uninstallation and clean up complete!"
}

possibly_add_repo() {
    print_step "Checking if helm repo is present..."
    if helm repo list 2>/dev/null | awk '{print $1}' | grep -q "^$HELM_REPO$"; then
        print_warning "Helm repo '$HELM_REPO' already exists, skipping add."
    else
        print_step "Adding repo '$HELM_REPO'..."
        helm repo add "$HELM_REPO" "$HELM_REPO_URL"
        print_step "Helm repo '$HELM_REPO' was added with URL '$HELM_REPO_URL'..."
    fi
}

install_new_helm_chart() {
    print_step "Installing new release..."

    # Add repo if needed
    possibly_add_repo

    # Setup dependencies
    print_step "Setting up dependencies for chart for $NAMESPACE..."
    helm dependency update $NAMESPACE/

    # Create namespace
    print_step "Creating namespace '$NAMESPACE'..."
    kubectl create namespace "$NAMESPACE"
    sleepy "Waiting for namespace creation" 3
    kubectl config set-context --current --namespace="$NAMESPACE"

    # Apply secrets
    print_step "Appying secrets..."
    kubectl apply -f $NAMESPACE-secret.yaml --namespace=$NAMESPACE

    # Apply persistent volumes
    print_step "Applying persistant volumes..."
    kubectl apply -f $NAMESPACE-minikube-persistent-volumes.yaml --namespace="$NAMESPACE"

    # Install helm chart
    print_step "Installing helm chart for release $RELEASE_NAME..."
    if helm install "$RELEASE_NAME" $NAMESPACE --namespace "$NAMESPACE" -f "$NAMESPACE-local-values.yaml"; then
       print_step "System '$NAMESPACE' installed successfully..."
    else
       print_warning "Installation of '$NAMESPACE' failed or timed out!"
       cleanup_failure
    fi

    # Wait for pods to be ready
    print_step "Waiting for all pods in '$NAMESPACE' to be running..."
    kubectl wait --for=condition=Ready pod --all --namespace="$NAMESPACE" --timeout=300s
}

print_deployment_info() {
    print_step "Setting up new helm release ($RELEASE_NAME) within NS $NAMESPACE."
    echo "Deploying $NAMESPACE..."
}

print_deployment_access() {
    MINIKUBE_IP=$(minikube ip)
    print_step "Cluster node port access:"
    kubectl get svc --all-namespaces --field-selector spec.type=NodePort -o json \
    | jq -r --arg ip "$MINIKUBE_IP" '
    .items[] |
    .metadata.namespace as $ns |
    .metadata.name as $name |
    .spec.ports[] |
    ($ns + " - " + $name + ": http://" + $ip + ":" + (.nodePort|tostring))
  '
}

print_step() {
    local step=$1
    echo ""
    echo -e "\e[32m▪ $step\e[0m"
}

print_warning() {
    local step=$1
    echo ""
    echo -e "\e[31m▪ $step\e[0m"
}

sleepy() {
    local duration=$2
    local dots="$1"
    local elapsed=0

    while [ $elapsed -lt $duration ]; do
        dots+="."
        echo -ne "\r$dots"
        sleep 1
        ((elapsed++))
    done
    echo ""
}

# script launch

script_setup "$@"
if [[ "$UNINSTALL" == "true" ]]; then
    uninstall_release
else
    start_minikube
fi
