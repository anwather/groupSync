Connect-AzAccount -Identity

$ctx = (Get-AzStorageAccount -ResourceGroupName groupSync -Name groupsync01).Context

Get-AzStorageBlobContent -Blob groups.csv -Destination $env:TEMP\groups.csv -Container groupsync -Context $ctx -Force

$connection = Get-AutomationConnection "AzureRunAsConnection"

Connect-AzureAd -TenantId $connection.TenantId `
    -ApplicationId $connection.ApplicationId `
    -CertificateThumbprint $connection.CertificateThumbprint

$csvFile = Import-Csv -Path $env:TEMP\groups.csv

foreach ($group in $csvFile) {
    $refGroup = Get-AzureAdGroup -ObjectId $group.InputGroupID

    $refMembers = Get-AzureAdGroupMember -ObjectId $refGroup.ObjectId

    $diffGroup = Get-AzureADMSGroup -Id $group.OutputGroupId

    $diffMembers = Get-AzureAdGroupMember -ObjectId $diffGroup.Id

    foreach ($member in $refMembers) {
        if ($member.ObjectId -notin ($diffMembers).ObjectId) {
            Write-Output "Adding $($member.DisplayName) to $($diffGroup.DisplayName)"
            Add-AzureADGroupMember -ObjectId $diffGroup.Id -RefObjectId $member.ObjectId
        }
    }
}