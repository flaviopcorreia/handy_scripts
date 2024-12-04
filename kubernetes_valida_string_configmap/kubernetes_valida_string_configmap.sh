CTX1="openshift-hlg/regionalizacao-api-hlg"
CTX2="openshift-hlg/regionalizacao-api-sit"


for CTX in $CTX1 $CTX2; do
echo "Checking configmap"
oc get cm --context $CTX -o yaml | grep prd -A 3 -B 3
echo ""
done
