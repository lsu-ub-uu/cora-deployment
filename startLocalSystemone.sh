helm repo add epc https://helm.epc.ub.uu.se/
helm repo update

cd helm

helm dependency update systemone/
kubectl create namespace systemone
kubectl apply -f systemone-secret.yaml --namespace=systemone
kubectl apply -f systemone-minikube-persistent-volumes.yaml
helm install my20250528systemone systemone --namespace systemone -f systemone-local-values.yaml