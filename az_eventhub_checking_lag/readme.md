# Objetivo

Alterar o valor de um {key=value} em um configmap de um deployment e fazer o rollout do deployment para utilizar a configmap alterada. 
# Como usar

1- Antes de utilizar este script, é necessário ter instalado os pacotes do "kubectl" no seu terminal linux e estar logado ao cluster kubernetes que deseja fazer a alterção.

2- Baixar o arquivo "kubernetes_change_configmap.sh" e edita-lo alterando as informações de seu cluster kubernetes (deployment/namespace/configmap).

3- Após editar o arquivo, basta executado "./kubernetes_change_configmap.sh"
