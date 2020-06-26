<#
 .SYNOPSIS
    Allow to login to Azure RM.

 .DESCRIPTION
    This script allows to login to Azure RM. It can use the parameters to fill the command or use the interactive console to select or input data.

 .PARAMETER
 .-user
    Defines the user name.
    Variable type [string].
    Example: usuario@outlook.com

 .-password
    Defines the password of the user.
    Variable type [string].
    Example: C0ntr4s3ñ4

 .-subscriptionId
    Defines the subscription ID.
    Variable type [string].
    Example: 1b08d938-e826-4bd3-8249-6fa39fdcd2d0

 .-v or -Verbose
    Sets Verbose mode ON.

.EXAMPLE

    .\PS_ARM_Login.ps1

    .\PS_ARM_Login.ps1 -user 'unUsuario' -password 'C0ntr4s3ñ4' -subscriptionId '1b08d938-e826-4bd3-8249-6fa39fdcd2d0'

#>

[CmdLetBinding()]
param(
 [string] $user,
 [string] $password,
 [string] $subscriptionId
)


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

$currentTime = (Get-Date)
Write-Verbose "$(fFormatDate) | Starting Login..."

if(!$user)
{
    $user = Read-Host "Enter user name"
}

if($password)
{
    $usrPassword = ConvertTo-SecureString -String $password -AsPlainText -Force
}
else
{
    $usrPassword = Read-Host -assecurestring "Enter password"
}

$cred = New-Object System.Management.Automation.PSCredential ($user, $usrPassword)

try
{
    $ErrorActionPreference = "Stop"
    Login-AzureRmAccount -Credential $cred | Out-Null
    Write-Verbose "$(fFormatDate) | Welcome. (Duration: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))"
}
catch
{
    fErrorParameter -texto "Wrong user name or password."
}
finally
{
    $ErrorActionPreference = "Continue"
}

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

Write-Verbose "$(fFormatDate) | Selecting subscription..."

select-azurermsubscription -SubscriptionId $subscription.SubscriptionId

sleep 0.01
Write-Verbose "$(fFormatDate) | Selected subscription: $($subscription.SubscriptionName)."
Write-Verbose "$(fFormatDate) | Welcome. (Duration: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))"