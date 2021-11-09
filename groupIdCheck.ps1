Connect-AzAccount -Identity

$ctx = (Get-AzStorageAccount -ResourceGroupName groupSync -Name groupsync01).Context

Get-AzStorageBlobContent -Blob groupId.csv -Destination $env:TEMP\groupId.csv -Container groupsync -Context $ctx -Force

$connection = Get-AutomationConnection "AzureRunAsConnection"

Connect-AzureAd -TenantId $connection.TenantId `
    -ApplicationId $connection.ApplicationId `
    -CertificateThumbprint $connection.CertificateThumbprint

$csvFile = Import-Csv -Path $env:TEMP\groupId.csv

$variations = @()

foreach ($line in $csvFile) {
    $group = Get-AzureAdGroup -SearchString $line.groupName
    if ($group.ObjectId -ne $line.ObjectId) {
        $obj = [PSCustomObject]@{
            GroupName = $line.GroupName
            Old_Id    = $line.ObjectId
            New_Id    = $group.ObjectId
        }
        $variations += $obj
    }
}

$uri = Get-AutomationVariable "logicAppUri"

Invoke-WebRequest -Uri $uri `
    -Method POST `
    -ContentType "application/json" `
    -Body $($variations | ConvertTo-Json) `
    -UseBasicParsing