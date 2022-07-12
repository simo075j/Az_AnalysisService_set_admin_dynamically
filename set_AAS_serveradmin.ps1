# Setting the variables:
$TenantId = "<your_tenantid>"
$AzInstanceName = "<your_AAS_server_name>"
$ResourceGroupName = "<RG_name_where_AAS_is_located>"
$adminUsers = "<your_user1>", "<your users2>" 
$adminGroups = "<your_adgroup1>", "<your_adgroup2>"  #This has to have a value e.g. NA
$adminApps = "<your_service_principal_name1>", "<your_service_principal_name2>"

#$currentAasAdmins = (Get-AzAnalysisServicesServer -Name $AzInstanceName -ResourceGroupName $ResourceGroupName).AsAdministrators | Select-Object -ExpandProperty $_
$adminGroupsId = $adminGroups | ForEach-Object {Get-AzADGroup -DisplayName $_ | Select-Object Id -ExpandProperty Id }
$adminAppsId = $adminApps | ForEach-Object { Get-AzADServicePrincipal -DisplayName $_ | Select-Object AppId -ExpandProperty AppId}
$updateAasAdmins = & {$adminUsers
    $adminGroupsId | ForEach-Object {"obj:" + $_+  "@" + $TenantId }
    $adminAppsId | ForEach-Object {"app:" + $_+  "@" + $TenantId }
    }
$updateAasAdmins = $updateAasAdmins | Where-Object{$_ -ne ""} | Sort-Object -Unique
Write-Host "Update AAS Admins"
Set-AzAnalysisServicesServer -Name $AzInstanceName -ResourceGroupName $ResourceGroupName -Administrator (($updateAasAdmins | Select-Object -ExpandProperty $_) -join ",")            
