# Group Management Runbooks

## Pre-Requisites

1) Create a Resource Group, Storage Account, Automation Account (when creating the automation account let it create a managed identity)
2) Create a container in the storage account to hold the CSV files.
3) Install the Az modules locally so you can deploy the solution

### Group Sync Runbook

1) In the Automation Account add the Azure AD module. Click on **Modules** -> **Browse Gallery** -> Search for Azure AD
2) Select the module and click **Select**
3) Change the **Runtime version** to 5.1 and click **Import**
4) Import the runbook by clicking on **Runbooks** -> **Import a runbook**
5) Browse to the groupSync.ps1 file, fill out the name details and ensure the **Runtime version** is 5.1. Click **Import**
6) You will have to review the runbook and update any hardcoded variables for the storage account. 
6) In the Automation Account click on **Run as accounts** -> **Azure Run As Account** -> **+Create** to create a new service principal. 
7) In the Automation Account click on **Identity** -> **Azure Role Assignments** -> **Add role assignment**. Follow the steps to give the identity the *Storage Account Contributor* role on the storage account created above.
8) In Azure AD click on **Roles and administrators**. Click on **Privileged role administrator** and add the service principal created (try searching for the automation account name - the service principal will have a big long string attached to the name)

When complete test the runbook by adding the CSV file to the storage account and running the runbook. 

### Group ID Check Runbook

1) Import the runbook by clicking on **Runbooks** -> **Import a runbook**
2) Browse to the groupSync.ps1 file, fill out the name details and ensure the **Runtime version** is 5.1. Click **Import**
3) You will have to review the runbook and update any hardcoded variables for the storage account.
4) Deploy the Logic App to a resource group by running the code below

```
New-AzResourceGroupDeployment -ResourceGroupName "update name" -TemplateFile .\azuredeploy.json -Verbose
```
5) Create a variable in the automation account to hold the URI for the Logic App by running the code below

```
$automationAccount = Get-AzAutomationAccount -ResourceGroupName "update value" -Name "update value"
$uri = Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName "update value" -Name emailGroupIdChanges -TriggerName manual
$automationAccount | New-AzAutomationVariable -Name logicAppUri -Encrypted $true -Value $uri.Value

When complete test the runbook by adding the CSV file to the storage account and running the runbook. 
