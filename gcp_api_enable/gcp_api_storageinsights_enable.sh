#!/bin/bash

# Verificar se o usuário está autenticado no GCP
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &>/dev/null; then
    echo "❌ Não há conta ativa no GCP. Faça login primeiro:"
    echo "gcloud auth login"
    exit 1
fi

echo "🔧 Habilitando Storage Insights API nos projetos GCP..."
echo "======================================================"

# Lista de projetos de produção
projects_prd=(
    "Project1"
    "Project2"
    "Project3"
)

# Lista de projetos de homologação
projects_hlg=(
    "Project1"
    "Project2"
    "Project3"
)

# Função para habilitar Storage Insights API
enable_storage_insights() {
    local project=$1
    echo "🔄 Habilitando Storage Insights API no projeto: $project"
    
    if gcloud services enable storageinsights.googleapis.com --project="$project" 2>/dev/null; then
        echo "✅ Storage Insights API habilitada com sucesso em: $project"
    else
        echo "❌ Erro ao habilitar Storage Insights API em: $project"
        return 1
    fi
}

# Função para verificar se a API já está habilitada
check_api_status() {
    local project=$1
    if gcloud services list --project="$project" --enabled --filter="name:storageinsights.googleapis.com" --format="value(name)" 2>/dev/null | grep -q "storageinsights.googleapis.com"; then
        return 0  # API já está habilitada
    else
        return 1  # API não está habilitada
    fi
}

# Contadores para estatísticas
total_projects=0
already_enabled=0
successfully_enabled=0
failed_enabled=0

# Combinar todas as listas de projetos
all_projects=("${projects_prd[@]}" "${projects_hlg[@]}")

# Processar todos os projetos
for project in "${all_projects[@]}"; do
    ((total_projects++))
    
    echo "📋 Verificando projeto: $project"
    
    # Verificar se o projeto existe
    if ! gcloud projects describe "$project" &>/dev/null; then
        echo "⚠️  Projeto não encontrado: $project"
        ((failed_enabled++))
        echo "-----------------------------------"
        continue
    fi
    
    # Verificar se a API já está habilitada
    if check_api_status "$project"; then
        echo "ℹ️  Storage Insights API já está habilitada em: $project"
        ((already_enabled++))
    else
        # Habilitar a API
        if enable_storage_insights "$project"; then
            ((successfully_enabled++))
        else
            ((failed_enabled++))
        fi
    fi
    
    echo "-----------------------------------"
done

# Criar arquivo de log com timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")
log_file="storage_insights_api_${timestamp}.log"

# Salvar resumo no arquivo de log
{
    echo "📊 Resumo da habilitação do Storage Insights API"
    echo "Executado em: $(date)"
    echo "=============================================="
    echo "Total de projetos processados: $total_projects"
    echo "APIs já habilitadas: $already_enabled"
    echo "APIs habilitadas com sucesso: $successfully_enabled"
    echo "Falhas: $failed_enabled"
    echo ""
    
    if [ $failed_enabled -eq 0 ]; then
        echo "✅ Todas as operações foram concluídas com sucesso!"
    else
        echo "⚠️  Algumas operações falharam. Verifique os logs para mais detalhes."
    fi
} > "$log_file"

# Exibir estatísticas finais
echo ""
echo "📊 Resumo da execução:"
echo "   - Total de projetos processados: $total_projects"
echo "   - APIs já habilitadas: $already_enabled"
echo "   - APIs habilitadas com sucesso: $successfully_enabled"
echo "   - Falhas: $failed_enabled"
echo ""
echo "📁 Log salvo em: $log_file"

if [ $failed_enabled -eq 0 ]; then
    echo "✅ Todas as operações foram concluídas com sucesso!"
else
    echo "⚠️  Algumas operações falharam. Verifique os logs para mais detalhes."
fi
