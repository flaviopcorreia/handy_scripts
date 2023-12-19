# Como usar

1- Antes de utilizar este script, é necessário coletar o ID do usuários que queira adicionar ao grupo e colar em um arquivo chamado users.txt.

2- Posteriormente, edite o script em qualquer editor de sua preferência (Sugestão Windows PowerShell ISE). Em seguida substitua o campo abaixo com o ID do grupo que deseja mover os usuários:

$targetgroup = 'ID_AQUI'

Obs: Para obter o ID do grupo, bastar executar o comando abaixo informando o nome do grupo:

Get-AzADGroup -DisplayName 'nome_do_grupo'

3- No passo de backup, informe o path que deseja utilizar para o backup:

Get-AzADGroupMember -GroupObjectId $targetgroup | export-csv 'path:\backup.csv'

4- No campo abaixo, informar o path com o arquivo 'users.txt' previamente definido no passo 1 do script:

$files = Get-Content "path:\users.txt"

5- Execução do script:
