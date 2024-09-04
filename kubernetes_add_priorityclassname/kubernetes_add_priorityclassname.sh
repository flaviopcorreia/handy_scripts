#Logando no context do cluster\n"
kubectx akspriv-oferta-hlg-admin

#Comando para adicionar o parametro priorityclass no arquivo do daemonset\n"
kubectl patch daemonset fluentd -n logging -p '{"spec":{"template":{"spec":{"priorityClassName":"system-cluster-critical"}}}}'
