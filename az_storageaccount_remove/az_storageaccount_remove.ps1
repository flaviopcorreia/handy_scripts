# Connect to Azure
Connect-AzAccount -UseDeviceAuthentication -Tenant "XXXX"
Set-AzContext -SubscriptionId "XXXX"

# Define target storage accounts and their resource groups
$targetAccounts = @(
    @{ Name = "storageaccount1"; ResourceGroup = "rg-storageaccount1" },
    @{ Name = "storageaccount2"; ResourceGroup = "rg-storageaccount2" },
    @{ Name = "storageaccount3"; ResourceGroup = "rg-storageaccount3" }
    # Add more accounts as needed
)

# Define the path for the log file
$logFile = "StorageAccountRemovalLog.txt"

# Clear previous log (if any)
if (Test-Path $logFile) {
    Remove-Item $logFile
}

foreach ($account in $targetAccounts) {
    $name = $account.Name
    $rg = $account.ResourceGroup
    Write-Host "Removing the storage account:" $name
    
    try {

        Remove-AzStorageAccount `
            -ResourceGroupName $rg `
            -Name $name `
            -Force 
       
        Start-Sleep -Seconds 7
        
        # Validation check
        $checkAccount = Get-AzStorageAccount `
            -ResourceGroupName $rg `
            -Name $name `
            -ErrorAction SilentlyContinue

        if ($null -eq $checkAccount) {
            $status = "✅ Removed successfully"
        } else {
            $status = "❌ Still exists or failed to delete"
        }
    }

    catch {
        $status = "❌ Error during removal: $_"
    }

    # Log result to file
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $name ($rg): $status"
    Add-Content -Path $logFile -Value $logEntry
}


