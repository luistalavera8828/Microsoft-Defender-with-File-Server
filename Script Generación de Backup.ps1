<#
.DESCRIPTION
Script de runbook que permite Generar un snapshot del File Shared de Azure File de Microsoft Azure.

.NOTES
Filename  : runbookbackup
Author    : Luis Talavera
Version   : 1.0
Date      : 26/05/2022
#>


Param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $AzureSubscriptionId,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $VaultName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $AzureFileShare,
    [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()]
    [Int] $RetentionDays = 30
)
  
$connectionName = "AzureRunAsConnection"

#Try {
#    #! Get the connection "AzureRunAsConnection "
#   $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
#  Write-Output "Iniciando Sesion en Microsoft Azure"
#    Add-AzureRmAccount -ServicePrincipal `
#        -TenantId $servicePrincipalConnection.TenantId `
#        -ApplicationId $servicePrincipalConnection.ApplicationId `
#        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
#}
#Catch {
#    If (!$servicePrincipalConnection) {
#        $ErrorMessage = "Conexión al $connectionName no encontrada"
#        throw $ErrorMessage
#    }
#    Else {
#        Write-Error -Message $_.Exception
#        throw $_.Exception
#    }
#}

Enable-AzureRmAlias -Scope CurrentUser
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId

$currentDate = Get-Date
$RetailTill = $currentDate.AddDays($RetentionDays)
Write-Output ("Los puntos de recuperación (RPO), se conservarán hasta el " + $RetailTill)

#! Set ARM vault resource
Write-Output ("Trabajando en la bóveda: " + $VaultName)
$vault = Get-AzureRmRecoveryServicesVault -Name $vaultName
Set-AzureRmRecoveryServicesVaultContext -Vault $vault
$containers = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureStorage
Write-Output ("Número de contenedores de copia de seguridad obtenidos: " + $containers.Count)

ForEach ($container in $containers) {
    Write-Output ("Trabajando en contenedores: " + $container.FriendlyName)
    #$fileshare = Get-AzureRmRecoveryServicesBackupItem -WorkloadType AzureFiles -Container $container | `
    #Where-Object {$_.Name -like "*$AzureFileShare*"}
    $fileshare = Get-AzureRmRecoveryServicesBackupItem -WorkloadType AzureFiles -Container $container
    If ($fileshare) {
        Write-Output ("Trabajando en File Share: " + $fileshare.Name)
        Backup-AzureRmRecoveryServicesBackupItem -Item $FileShare -ExpiryDateTimeUTC $RetailTill
    }
    else
    {
     Write-Output ("Trabajando en File Share: " + $fileshare.Name)
     Backup-AzureRmRecoveryServicesBackupItem -Item $fileshare -ExpiryDateTimeUTC $RetailTill
    }

    
}
Write-Output ("")
