#!/usr/bin/env bash
  
# Obter os namespaces, exceto os especificados
namespaces=$(kubectl get po --all-namespaces -o wide | awk 'NR>1 && !/kube-system|default|kube-node-lease|kube-public/ {print $1}' | uniq)

# Loop através dos namespaces para adicionar uma annotation que no caso é "kubernetes.azure.com/scalesetpriority" com o valor "Spot"
for namespace in $namespaces; do
  # Aplicar o patch para cada namespace
  kubectl patch --type='merge' namespace "$namespace" -p '{"metadata":{"annotations":{"scheduler.alpha.kubernetes.io/defaultTolerations": "[{\"Key\": \"kubernetes.azure.com/scalesetpriority\",\"Operator\": \"Equal\", \"Value\": \"spot\", \"Effect\": \"NoSchedule\"}]"} } }'
done
