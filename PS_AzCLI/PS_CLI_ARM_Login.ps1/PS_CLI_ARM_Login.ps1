<#
 .SYNOPSIS
    Allow to login to Azure RM CLI.

 .DESCRIPTION
    This script allows to login to Azure RM CLI. It can use the parameters to fill the command or use the interactive console to select or input data.

 .PARAMETER
 .-user
    Defines the user name.
    Variable type [string].
    Example: usuario@outlook.com

 .-password
    Defines the password of the user.
    Variable type [string].
    Example: C0ntr4s3ñ4

.EXAMPLE

    .\PS_CLI_ARM_Login.ps1 -user 'unUsuario' -password 'C0ntr4s3ñ4'

#>


param(
 [string] $user,
 [string] $password
)

<# Funciones #>

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

<# Script #>

$currentTime = (Get-Date)
Write-Host "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | Inicio de Login..."

if(!$user)
{
    $user = Read-Host "Ingrese el usuario"
}

if(!$password)
{
    $usrPassword = Read-Host  "Ingrese su password"
}

az login -u $user -p $usrPassword | Out-Null

$subscription = az account list | ConvertFrom-Json

fEnumerateList -array $subscription | select Item,name,id,isDefault | ft
$pos = Read-Host "Ingresar N°"
$subscription = $subscription[$pos-1]

az account set --subscription $subscription.id

Write-Host "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | Ingreso a la suscripción: $($subscription.name). (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))"
