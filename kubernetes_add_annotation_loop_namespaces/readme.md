Objetivo
Adicionar uma annotation em todos os namespaces do cluster kubernetes, especificando os namespaces em exceções.

Como usar
1- Antes de utilizar este script, é necessário ter instalado os pacotes do "kubectl" no seu terminal linux e estar logado ao cluster kubernetes que deseja fazer a inclusão.

2- Baixar o arquivo "kubernetes_add_annotation_loop_namespaces.sh" e edita-lo incluindo os namespaces que não queira adicionar a annotation (exclusão) e preencher com a annotation que quer adicionar.

3- Após editar o arquivo, basta executado "./kubernetes_add_annotation_loop_namespaces.sh"
