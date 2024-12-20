# Objetivo

Fazer uma consulta em todos os NODES do cluster kubernetes ou openshift que esteja conectado, trazendo informações do uso total de CPU/MEM Requests/Limits por node.
Essa consulta fará uma soma dos recursos Requests/Limits de todos os PODs do respectivo node e também trará informações em percentagem do quanto desses valores de fato está sendo utilizado.
# Como usar

1- Antes de utilizar este script, é necessário ter instalado o pyhton 3.12 e os pacotes abaixo:

pip install json

pip install subprocess

2- Baixar o arquivo "kubernetes_valida_cpu_memory_nodes_usage_XX.py" e edita-lo alterando as informações do valor do NODE que deseja incluir na filtro da busca.

Filter nodes containing "VALOR_DA_BUSCA" in their name
      if "VALOR_DA_BUSCA" not in node_name:
            continue
            
3- Após editar o arquivo, basta executa-lo "kubernetes_valida_cpu_memory_nodes_usage_XX.py"

