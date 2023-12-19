#Informar o ID do grupo que deseja adicionar os usuários 'ID_AQUI'
$targetgroup = 'ID_AQUI'

#Listar quantidade de usuários no grupo
Get-AzADGroupMember -GroupObjectId $targetgroup | Measure-Object

#Fazer backup dos membros do grupo em um arquivo CSV.
Get-AzADGroupMember -GroupObjectId $targetgroup | export-csv 'path:\backup.csv' 

#Adicionar os usuários ao grupo. No item "path:\file.txt" abaixo, adicionar o path do arquivo txt que contenha o ID dos usuários que queira adicionar aos grupo.
$files = Get-Content "path:\file.txt"

#Função para adicionar os usuários ao respectivo grupo
foreach ($file in $files) {
    $move = Add-AzADGroupMember -TargetGroupObjectId $targetgroup -MemberObjectId $file 
}
