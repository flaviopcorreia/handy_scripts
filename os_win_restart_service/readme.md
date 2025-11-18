# Objetivo

Verificar o status de determinado serviço que no caso é o Print Spooler. Caso o serviço esteja como RUNNING, ele fará o STOP e posteriormente o START. Se o processo de STOP falhar, ele fará uma nova tentativa. Caso o serviço já esteja com status de STOPPED, o script apenas fará o START do serviço.

# Como usar

1- Edite o script especificando o serviço que deseja reiniciarlizar na variável "$serviceName"

2- Execute o script em modo Admistrativo.
