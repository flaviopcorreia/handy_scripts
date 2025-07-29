# Connect to Azure
Connect-AzAccount -UseDeviceAuthentication -Tenant "XXX"
Set-AzContext -SubscriptionId "XXX"

# Define target storage accounts and their resource groups
$targetAccounts = @(
    @{ Name = "storageaccount1"; ResourceGroup = "rg-storageaccount1" },
    @{ Name = "storageaccount2"; ResourceGroup = "rg-storageaccount2" },
    @{ Name = "storageaccount3"; ResourceGroup = "rg-storageaccount3" }
    # Add more accounts as needed
)

foreach ($account in $targetAccounts) {
    Write-Host "Disabling public network access for:" $account.Name

    Set-AzStorageAccount `
        -ResourceGroupName $account.ResourceGroup `
        -Name $account.Name `
        -PublicNetworkAccess Disabled

    Start-Sleep -Seconds 5
    Write-Host "Public access disabled for:" $account.Name

# ——— Validation: only check PublicNetworkAccess ———
    $publicAccess = (Get-AzStorageAccount `
        -ResourceGroupName $account.ResourceGroup `
        -Name $account.Name
    ).PublicNetworkAccess

    if ($publicAccess -eq 'Disabled') {
        Write-Host "✅ Validation passed: PublicNetworkAccess is Disabled" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Validation failed: PublicNetworkAccess is $publicAccess" -ForegroundColor Red
    }

    Write-Host ""
}
