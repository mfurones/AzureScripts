<#
 .SYNOPSIS
    Allow to report all Resources in Azure RM.

 .DESCRIPTION
    This script allows to report all Resources in Azure RM.

 .PARAMETER
 .-resourceGroupName
    Defines the Resource Group name.
    Variable type [string].
    Example: RG_Test

 .-v or -Verbose
    Sets Verbose mode ON.

.EXAMPLE

    .\PS_ARM_ResourceRemove.ps1

    .\PS_ARM_ResourceRemove.ps1 -resourceGroupName RG_Test

#>

[CmdLetBinding()]
param()

<#
******************************************************************************
Parametros
******************************************************************************
#>

$subscriptionID = (Get-AzureRmContext).Subscription.SubscriptionId


<#
******************************************************************************
Funciones
******************************************************************************
#>

<# Formato Fecha #>

function fFormatDate
{
    param()
    process
    {
        return "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T)"
    }
}


<#
******************************************************************************
Script
******************************************************************************
#>

$currentTime = (Get-Date)
Write-Verbose "$(fFormatDate) | Starting Script..."

<# Resource Group #>

Write-Verbose "$(fFormatDate) | Searching Resources..."

$resources = Find-AzureRmResource -ErrorAction SilentlyContinue | select Name,ResourceGroupName,Location,ResourceType,Kind

$Archivo = "Resources_Reporte_[$($subscriptionID)].csv"
$resources | export-csv $Archivo

Write-Verbose "$(fFormatDate) | End of script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))"