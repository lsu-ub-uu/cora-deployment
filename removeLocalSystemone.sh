kubectl delete namespace systemone
kubectl get pv -o name | grep "^persistentvolume/systemone" | xargs -r kubectl delete
minikube ssh -- "sudo rm -rf /mnt/minikube/systemone/"