<#
 .SYNOPSIS
    Allow to create a SQL Logic Server.

 .DESCRIPTION
    This script allows to create a SQL Logic Server. It can use the parameters to fill the command or use the interactive console to select or input data.

 .PRE-REQUISITES
    - Mandatory:
        - Existing Resosurce Group.
    
 .PARAMETER
 .-resourceGroupName
    Defines the resource group name.
    Variable type [string].

 .-SQLServerName
    Defines the SQL Logic Server Name.
    Variable type [string].

 .-sqlUSR
    Defines the SQL Server User Name.
    Variable type [string].

 .-sqlPASS
    Defines the SQL Server Password.
    Variable type [string].
    
 .EXAMPLE

    .\PS_ARM_SQLLogicServerCreate.ps1 -resourceGroupName RG-Demo -SQLServerName sqlserverdemo01 -sqlUSR usuariodemo -sqlPASS P4ssw0rd@1

#>

[CmdLetBinding()]
param
(
    [string] $resourceGroupName,

    [string] $SQLServerName,
 
    [string] $sqlUSR,
    [string] $sqlPASS

)

<#
******************************************************************************
Funciones
******************************************************************************
#>


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

function ferrorParameter
{
    param(
        [string] $texto
    )
    process
    {
        Write-host "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | $($texto)" -ForegroundColor Red
        Write-host "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | fin del script"
        exit 1
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

Write-Verbose "$(fFormatDate) | Searching Resource Group..."
if ($resourceGroupName)
{
    $resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName  -ErrorAction SilentlyContinue
    if (!$resourceGroup) {fErrorParameter -texto "Definition error. Wrong name for Resource group."}
}
else
{
    $TMP = Get-AzureRmResourceGroup -ErrorAction SilentlyContinue
    Write-Host "List of Resource Groups"
    Write-Host "------------------------------"
    fEnumerateList -array $TMP | Select-Object Item,ResourceGroupName | Format-Table
    $pos = Read-Host "Enter N°"
    $resourceGroup = $TMP[$pos-1]
}

<# SQL Server #>

if (!$SQLServerName) {$SQLServerName = Read-Host "Enter SQL Server Name"}

Write-Verbose "$(fFormatDate) | Searching SQL Server..."
$SQLServer = get-AzureRmSqlServer -ResourceGroupName $resourceGroup.ResourceGroupName -ServerName $SQLServerName -ErrorAction SilentlyContinue
if ($SQLServer) {fErrorParameter -texto "Definition error. The SQL Server Name $($SQLServerName) already exist."}

if (!$sqlUSR) {$sqlUSR = Read-Host "Enter SQL Server User Name"}

if ($sqlPASS) {$password = ConvertTo-SecureString -String $sqlPASS -AsPlainText -Force}
else {$password = Read-Host -assecurestring "Enter SQL Server Password"}

$cred =  New-Object System.Management.Automation.PSCredential($sqlUSR, $password)

Write-Verbose "$(fFormatDate) | Creating SQL Server..."
$SQLServer = New-AzureRmSqlServer -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -ServerName $SQLServerName -SqlAdministratorCredentials $cred -ErrorAction SilentlyContinue

if(!$SQLServer) {fErrorParameter -texto "Deployment error"}

Write-Verbose "$(fFormatDate) | End of script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))"

