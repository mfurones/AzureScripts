<#
 .SYNOPSIS
    Allow to create a Storage Account Container in Azure RM.

 .DESCRIPTION
    This script allows to create a Storage Account Container in Azure RM. It can use the parameters to fill the command or use the interactive console to select or input data.

 .PARAMETER
 .-resourceGroupName
    Defines the Resource Group name.
    Variable type [string].

 .-StorageAccountName
    Defines the Storage Account name.
    Variable type [string].
    Input: must be written in lowercase and numbers. Name must be between 3 and 23 characters.

 .-StorageAccountContainerName
    Defines the Container name.
    Variable type [string].

 .-v or -Verbose
    Sets Verbose mode ON.

.EXAMPLE

    .\PS_ARM_StorageAccountContainerCreate.ps1

    .\PS_ARM_StorageAccountContainerCreate.ps1 -resourceGroupName RG-Demo -StorageAccountName sademo01 -StorageAccountContainerName ContLogs

#>

[CmdLetBinding()]
param(
 [string] $resourceGroupName,
 [string] $StorageAccountName,
 [string] $StorageAccountContainerName
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
    echo "------------------------------"
    fEnumerateList -array $TMP | select Item,ResourceGroupName | ft
    $pos = Read-Host "Enter N°"
    $resourceGroup = $TMP[$pos-1]
}


<# Storage Account #>

Write-Verbose "$(fFormatDate) | Searching Storage Account..."
if ($StorageAccountName)
{
    $StorageAccount = Get-AzureRmStorageAccount -Name $StorageAccountName -ResourceGroupName $resourceGroup.ResourceGroupName  -ErrorAction SilentlyContinue
    if (!$StorageAccount) {fErrorParameter -texto "Definition error. Wrong name for Storage Account."}
}
else
{
    $TMP = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
    Write-Host "List of Storage Account"
    echo "------------------------------"
    fEnumerateList -array $TMP | select Item,StorageAccountName | ft
    $pos = Read-Host "Enter N°"
    $StorageAccount = $TMP[$pos-1]
}

<# Container #>
Write-Verbose "$(fFormatDate) | Searching Container..."

$SAK = (Get-AzureRmStorageAccountKey -Name $StorageAccount.StorageAccountName -ResourceGroupName $resourceGroup.ResourceGroupName).Value[0]
$SAC = New-AzureStorageContext -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey $SAK

$Container = get-AzureStorageContainer -Name $StorageAccountContainerName -Context $SAC -ErrorAction SilentlyContinue

if ($Container) {fErrorParameter -texto "The container $($StorageAccountContainerName) already exists."}
else
{
    Write-Verbose "$(fFormatDate) | Creating Container..."
    $Container = New-AzureStorageContainer -Name $StorageAccountContainerName -Context $SAC
}

Write-Verbose "$(fFormatDate) | End of script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))"
