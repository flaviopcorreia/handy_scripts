#Definir as variveis abaixo informando os valores pertinentes ao seu deployment e configmpa que no caso abaixo é o "data"
  
CONFIGMAP_NAME="XXX"
NAMESPACE="XXX"
JSON_PATCH='{"data":{"key":"value"}}'
DEPLOYMENT="XXX"

echo -e "\n Alterando configmap $CONFIGMAP_NAME do deployment $DEPLOYMENT"

kubectl patch configmap $CONFIGMAP_NAME -n $NAMESPACE -p "$JSON_PATCH"

echo -e "\n Aguandado 30 segundos para mostrar o valor do configmap alterado"

sleep 30

#Alterar valor do grep

#No valor do grep, informe a "key" usado na variavel $JSON_PATCH.

kubectl get cm $CONFIGMAP_NAME -n $NAMESPACE -o yaml | grep "key"

echo -e "\n Fazendo rollout das pods $DEPLOYMENT"

kubectl rollout restart deployment/$DEPLOYMENT -n $NAMESPACE

echo -e "\n Aguandado 2 minutos para mostrar os status das pods que fizeram rollout"

sleep 120

kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT
