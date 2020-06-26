<#
 .SYNOPSIS
    Allow to select a specific subscription in Azure RM.

 .DESCRIPTION
    This script allows to select a specific subscription in Azure RM. It can use the parameters to fill the command or use the interactive console to select or input data.

 .PARAMETER
 .-subscriptionId
    Defines the subscription ID.
    Variable type [string].
    Example: 1b08d938-e826-4bd3-8249-6fa39fdcd2d0

 .-v or -Verbose
    Sets Verbose mode ON

.EXAMPLE

    .\PS_ARM_SubscriptionSelect.ps1 -subscriptionId '1b08d938-e826-4bd3-8249-6fa39fdcd2d0'

#>

[CmdLetBinding()]
param(
 [string] $subscriptionId
)

<#
******************************************************************************
Functions
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


<# Error Output #>

function fErrorParameter
{
    param(
        [string] $texto
    )
    process
    {
        Write-host "$(fFormatDate) | $($texto)" -ForegroundColor Red
        Write-host "$(fFormatDate) | End of the script."
        exit 1
    }
}


<# Listado #>

function fEnumerateList
{
    param(
        [array] $array
    )
    process
    {
        $ar = $array | ConvertTo-Csv -NoTypeInformation
        for($i=0; $i -lt $ar.Count; $i++) {
            if($i) {$ar[$i] = "`"$($i)`","+ $ar[$i]}
            else {$ar[$i] = "`"Item`","+ $ar[$i]}
        }
        return $ar | ConvertFrom-Csv
    }
}

<#
******************************************************************************
Script
******************************************************************************
#>

<# Subscription #>

Write-Verbose "$(fFormatDate) | Searching subscription..."
if ($subscriptionId)
{
    $subscription = Get-azurermsubscription -SubscriptionId $subscriptionId  -ErrorAction SilentlyContinue
    if(!$subscription) {fErrorParameter -texto "Wrong subscriptionId."}
}
else
{
    $TMP = Get-AzureRmSubscription -ErrorAction SilentlyContinue
    Write-Host "List of subscription"
    echo "------------------------------"
    fEnumerateList -array $TMP | select Item,SubscriptionName,SubscriptionId | ft
    $pos = Read-Host "Ingresar N°"
    $subscription = $TMP[$pos-1]
}

select-azurermsubscription -SubscriptionId $subscription.SubscriptionId

sleep 0.01
Write-Verbose "$(fFormatDate) | Ingreso a la suscripción: $($subscription.SubscriptionName)."
Write-Verbose "$(fFormatDate) | End of the script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))"
