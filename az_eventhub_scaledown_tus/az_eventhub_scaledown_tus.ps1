Param( 
    [Parameter(Mandatory=$True, 
                ValueFromPipelineByPropertyName=$false, 
                HelpMessage='Especifique o nome do Event-HUB', 
                Position=1)]
                [String] 
                $eventhub, 
                   
    [Parameter(Mandatory=$True, 
                ValueFromPipelineByPropertyName=$false, 
                HelpMessage='Especifique o nome do grupo de recursos', 
                Position=2)] 
                [String] 
                $resourceGroupName, 

    [Parameter(Mandatory=$True, 
                ValueFromPipelineByPropertyName=$false, 
                HelpMessage='Especifique a Subscription ID', 
                Position=3)]   
                [String] 
                $subscriptionId,  

    [Parameter(Mandatory=$True, 
                ValueFromPipelineByPropertyName=$false, 
                HelpMessage='Especifique o Tier do Event-HUB (Basic, Standard ou Premium)', 
                Position=4)] 
                [String] 
                $tier,

    [Parameter(Mandatory=$True, 
                ValueFromPipelineByPropertyName=$false, 
                HelpMessage='Especifique a quantidade de Throughput Unit para o Event-HUB', 
                Position=5)] 
                [String] 
                $throughputunit
    ) 

# Ensures you do not inherit an AzContext in your runbook 
Disable-AzContextAutosave -Scope Process | Out-Null 
   
# Connect to Azure with system-assigned managed identity 
Write-Output "Conectando com system-assigned managed identity"
$AzureContext = (Connect-AzAccount -Identity).context
Write-Output $AzureContext
 
$subscriptionname = Get-AzSubscription -SubscriptionId $subscriptionId | Select Name
  
Write-Output "--- Checking the throughput unit value of the Event-HUB '$eventhub' ..."

# Get the current Event Hub namespace details
try {
    $currentEventHub = Get-AzEventHubNamespace -ResourceGroupName $resourceGroupName -NamespaceName $eventhub
    $currentCapacity = $currentEventHub.SkuCapacity
    $location = $currentEventHub.Location
} catch {
    Write-Error "Failed to retrieve the Event Hub namespace. Error: $_"
    throw
}

# Validate location
if ([string]::IsNullOrEmpty($location)) {
    Write-Warning "Location property is empty. Setting a default location."
    $location = "Brazil South" # Replace with your default location
}

Write-Output "Current throughput unit: $currentCapacity"
Write-Output "Current location: $location"

# Check and update capacity if needed
if ($currentCapacity -eq $throughputunit) {
    Write-Output "The throughput unit is already set to $throughputunit. No action is required."
} else {
    Write-Output "The throughput unit is $currentCapacity. Updating to $throughputunit..."
    Set-AzEventHubNamespace -ResourceGroupName $resourceGroupName `
                            -NamespaceName $eventhub `
                            -SkuName $tier `
                            -SkuCapacity $throughputunit `
                            -Location $location
    Write-Output "The throughput unit has been successfully updated to $throughputunit."
}
