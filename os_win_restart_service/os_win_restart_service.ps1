# Script para reiniciar o serviço Print Spooler
# Data de criação: 2025-11-11

$serviceName = "Spooler"  
$logFile = "D:\Logs\PrintSpooler_Restart_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$maxRetries = 2

# Função para escrever no log
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# Criar diretório de logs se não existir
$logDir = Split-Path -Path $logFile -Parent
if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Início do script
Write-Log "=========================================="
Write-Log "Iniciando processo de reinicialização do Print Spooler"
Write-Log "=========================================="

try {
    # Verificar status inicial do serviço
    $service = Get-Service -Name $serviceName
    Write-Log "Status inicial do serviço: $($service.Status)"

    # Passo 1: Parar o serviço
    Write-Log "Parando o serviço Print Spooler..."
    Stop-Service -Name $serviceName -Force
    Write-Log "Comando STOP enviado ao serviço"
    
    # Passo 2: Aguardar 4 minutos
    Write-Log "Aguardando 4 minutos..."
    Start-Sleep -Seconds 240

    # Passo 3: Verificar se o serviço parou
    $service = Get-Service -Name $serviceName
    Write-Log "Status do serviço após 4 minutos: $($service.Status)"

    if ($service.Status -ne "Stopped") {
        Write-Log "AVISO: Serviço ainda está em execução. Tentando parar novamente..."
        
        # Tentativa 2 de parar o serviço
        Stop-Service -Name $serviceName -Force
        Write-Log "Segundo comando STOP enviado ao serviço"
        
        # Aguardar um pouco para o serviço parar
        Start-Sleep -Seconds 30
        
        # Verificar novamente o status
        $service = Get-Service -Name $serviceName
        Write-Log "Status do serviço após segunda tentativa: $($service.Status)"
        
        if ($service.Status -ne "Stopped") {
            Write-Log "ERRO: Não foi possível parar o serviço após 2 tentativas. Status atual: $($service.Status)"
            Write-Log "Saindo do script sem iniciar o serviço."
            Write-Log "=========================================="
            exit 1
        }
    }

    # Passo 4: Serviço está parado, iniciar o serviço
    Write-Log "Serviço parado com sucesso. Iniciando o serviço Print Spooler..."
    Start-Service -Name $serviceName
    Write-Log "Comando START enviado ao serviço"

    # Passo 5: Aguardar 2 minutos
    Write-Log "Aguardando 2 minutos para verificar a inicialização..."
    Start-Sleep -Seconds 120

    # Passo 6: Verificar se o serviço iniciou
    $service = Get-Service -Name $serviceName
    Write-Log "Status do serviço após 2 minutos: $($service.Status)"

    if ($service.Status -eq "Running") {
        Write-Log "SUCESSO: Serviço Print Spooler reiniciado com sucesso!"
        Write-Log "=========================================="
        exit 0
    } else {
        Write-Log "AVISO: Serviço não está em execução. Status atual: $($service.Status)"
        Write-Log "=========================================="
        exit 1
    }

} catch {
    Write-Log "ERRO: Ocorreu um erro durante a execução do script"
    Write-Log "Detalhes do erro: $($_.Exception.Message)"
    Write-Log "=========================================="
    exit 1
}
