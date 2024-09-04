#Logando no context do cluster"
kubectx "informe o nome de seu kubernetes"

#Comando para adicionar o parametro priorityclass no arquivo do daemonset usando a name system-cluster-critical"
kubectl patch daemonset fluentd -n logging -p '{"spec":{"template":{"spec":{"priorityClassName":"system-cluster-critical"}}}}'
