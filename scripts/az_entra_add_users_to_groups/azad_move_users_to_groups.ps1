$targetgroup = 'ID_AQUI'

#Listar quantidade de usuários no grupo
Get-AzADGroupMember -GroupObjectId $targetgroup | Measure-Object

#Fazer backup dos membros do grupo em um arquivo CSV.
Get-AzADGroupMember -GroupObjectId $targetgroup | export-csv 'path:\backup.csv' 

#Adicionar os usuários ao grupo. 
$files = Get-Content "path:\file.txt"
foreach ($file in $files) {
    $move = Add-AzADGroupMember -TargetGroupObjectId $targetgroup -MemberObjectId $file 
}
