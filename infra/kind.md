
```shell
$ kind create cluster --name cicd001 --config kind-config.yaml
$ kubectl get nodes

NAME                    STATUS   ROLES           AGE    VERSION
my-kind-control-plane   Ready    control-plane   139d   v1.32.2
my-kind-worker          Ready    <none>          139d   v1.32.2
my-kind-worker2         Ready    <none>          139d   v1.32.2
```