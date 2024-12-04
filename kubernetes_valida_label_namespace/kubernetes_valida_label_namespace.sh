#Defina o "AKS name" que queira fazer a analise. Não utilizar "akspriv" nem "-admin" do "AKS name" pois é preenchido no script abaixo:

AKS1="abastecimento-hlg"
AKS2="faturamento-hlg"

for CTX in $AKS1 $AKS2; do
echo "Checking namespaces for context: akspriv-$CTX-admin"
kubectl get namespaces --context "akspriv-$CTX-admin" --selector istio-injection=enabled --show-labels
echo ""
done
