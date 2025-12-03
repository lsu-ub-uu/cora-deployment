# cora-deployment

This repo hold helm charts for systemOne, Alvin and DiVA.

start minikube, adjust as needed

```bash
minikube start --memory 32192 --cpus 16 --mount --mount-string "/mnt/someplace/minikube/:/mnt/minikube"

```

## To use dockers from epc repository

```bash
helm repo add epc https://helm.epc.ub.uu.se/
helm repo update
```

## Install systemOne locally from epc repository

```bash
kubectl create namespace systemone-epc
kubectl apply -f systemone-secret.yaml --namespace=systemone-epc
kubectl apply -f systemone-minikube-persistent-volumes.yaml --namespace systemone-epc
helm install my20251203systemone epc/systemone --namespace systemone-epc -f systemone-local-values.yaml

#or search and deploy specific version
helm search repo epc
helm install my20251203systemone epc/systemone --namespace systemone-epc --version 0.7.31 -f systemone-local-values.yaml
```

## Run systemOne locally using minicube, with fitnesse and jsclient

```bash
cd helm
helm dependency update systemone/
kubectl create namespace systemone
kubectl apply -f systemone-secret.yaml --namespace=systemone
kubectl apply -f systemone-minikube-persistent-volumes.yaml --namespace=systemone
helm install my20251203systemone systemone --namespace systemone -f systemone-local-values.yaml
```

you can watch the progress with:

```bash
watch -n 1 '
  kubectl get pod,service,jobs -n systemone;
  echo;
  echo "🐳 Images in use:";
  kubectl get pods -n systemone -o jsonpath="{range .items[*]}{range .spec.containers[*]}{.image}{\"\n\"}{end}" | sort | uniq;
  echo;
  helm -n systemone ls
'
```

get your minikube ip: minikube ip

This should start a local version of systemOne accessable at:<br>

- rest: http://192.168.49.2:30980/rest/
- login: http://192.168.49.2:30980/login/
- jsClient: http://192.168.49.2:30980/jsclient/
- idplogin: http://192.168.49.2:30980/idplogin/
- fitnesse: http://192.168.49.2:30980/fitnesse/

### to remove and start over

```bash
kubectl delete namespace systemone
kubectl get pv -o name | grep "^persistentvolume/systemone" | xargs -r kubectl delete
minikube ssh -- "sudo rm -rf /mnt/minikube/systemone/"
```

## Run Alvin locally using minicube, with fitnesse and jsclient

```bash
cd helm
helm dependency update alvin/
kubectl create namespace alvin
kubectl apply -f alvin-secret.yaml --namespace=alvin
kubectl apply -f alvin-minikube-persistent-volumes.yaml --namespace=alvin
helm install my20251203alvin alvin --namespace alvin -f alvin-local-values.yaml
```

you can watch the progress with:

```bash
watch -n 1 '
  kubectl get pod,service,jobs -n alvin;
  echo;
  echo "🐳 Images in use:";
  kubectl get pods -n alvin -o jsonpath="{range .items[*]}{range .spec.containers[*]}{.image}{\"\n\"}{end}" | sort | uniq
  echo;
  helm -n alvin ls
'


```

get your minikube ip: minikube ip

This should start a local version of alvin accessable at:<br>

- rest: http://192.168.49.2:30981/rest/
- login: http://192.168.49.2:30981/login/
- jsClient: http://192.168.49.2:30981/jsclient/
- idplogin: http://192.168.49.2:30981/idplogin
- fitnesse: http://192.168.49.2:30981/fitnesse/
- alvinclient: http://192.168.49.2:30981/alvinclient


### to remove and start over

```bash
kubectl delete namespace alvin
kubectl get pv -o name | grep "^persistentvolume/alvin" | xargs -r kubectl delete
minikube ssh -- "sudo rm -rf /mnt/minikube/alvin/"
```

## Run DiVA locally using minicube, with fitnesse and jsclient

```bash
cd helm
helm dependency update diva/
kubectl create namespace diva
kubectl apply -f diva-secret.yaml --namespace=diva
kubectl apply -f diva-minikube-persistent-volumes.yaml --namespace=diva
helm install my20251203diva diva --namespace diva -f diva-local-values.yaml
```

you can watch the progress with:

```bash
watch -n 1 '
  kubectl get pod,service,jobs -n diva;
  echo;
  echo "🐳 Images in use:";
  kubectl get pods -n diva -o jsonpath="{range .items[*]}{range .spec.containers[*]}{.image}{\"\n\"}{end}" | sort | uniq
  echo;
  helm -n diva ls
'


```

get your minikube ip: minikube ip

This should start a local version of diva accessable at:<br>

- rest: http://192.168.49.2:30982/rest/
- login: http://192.168.49.2:30982/login/
- jsClient: http://192.168.49.2:30982/jsclient/
- idplogin: http://192.168.49.2:30982/idplogin/
- fitnesse: http://192.168.49.2:30982/fitnesse/
- divaclient: http://192.168.49.2:30982/divaclient
- playwright: http://192.168.49.2:30782

### Running Playwright locally

Playwright UI uses Service workers and requires running on localhost (or HTTPS). Use port forwarding to access it locally.

```bash
  kubectl -n diva port-forward service/diva-playwright 8080:8080
```

Then the tests are available at http://localhost:8080

### to remove and start over

```bash
kubectl delete namespace diva
kubectl get pv -o name | grep "^persistentvolume/diva" | xargs -r kubectl delete
minikube ssh -- "sudo rm -rf /mnt/minikube/diva/"
```
