<#
 .SYNOPSIS
    Allow to create a Storage account in Azure RM.

 .DESCRIPTION
    This script allows to create a Storage account in Azure RM. It can use the parameters to fill the command or use the interactive console to select or input data.

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

 .-SkuName
    Defines the Sku.
    Variable type [string].
    Example: Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS

 .-v or -Verbose
    Sets Verbose mode ON.

.EXAMPLE

    .\PS_ARM_StorageAccountCreate.ps1

    .\PS_ARM_StorageAccountCreate.ps1 -resourceGroupName RG-Demo -StorageAccountName sademo01 -StorageAccountContainerName vhds -SkuName Standard_GRS

#>

[CmdLetBinding()]
param(
 [string] $resourceGroupName,
 [string] $StorageAccountName,
 [string] $StorageAccountContainerName = "vhds",
 [string] $SkuName
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

if(!$StorageAccountName)
{
    $StorageAccountName = Read-Host "Enter Storage Account name"
}

if (!($StorageAccountName -cmatch "^[a-z]+[a-z0-9]{2,}$"))
{
    fErrorParameter -texto "Definition error. The options for -StorageAccountName are: Only lowercase letters and numbers. Name must be between 3 and 23 characters."
}

Write-Verbose "$(fFormatDate) | Checking Storage Account..."
$StorageAccount = Get-AzureRmStorageAccount -AccountName $StorageAccountName -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue

if ($StorageAccount)
{
    fErrorParameter -texto "The Storage Account $($StorageAccountName) already exist."
}
else
{
    $SkuList = 'Standard_LRS','Standard_ZRS','Standard_GRS','Standard_RAGRS','Premium_LRS'

    if ($SkuName)
    {
        if ($SkuList.IndexOf($SkuName) -lt 0) {fErrorParameter -texto "Definition error. The options for -SkuName are: Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."}
    }
    else
    {
        $TMP = $SkuList | ForEach-Object {[PSCustomObject]@{SkuName = $_}}
        Write-Host "List of Storage Account Sku"
        echo "------------------------------"
        fEnumerateList -array $TMP | select Item,SkuName | ft
        $pos = Read-Host "Enter N°"
        $SkuName = $TMP[$pos-1].SkuName
    }
    
    Write-Verbose "$(fFormatDate) | Creating Storage Account..."
    $storageAccount = new-AzureRmStorageAccount -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -Name $StorageAccountName -SkuName $SkuName

    if ($storageAccount) {Write-Verbose "$(fFormatDate) | Storage Account $($StorageAccountName) finished."}
    else {fErrorParameter -texto "Unexpected error."}

    Write-Verbose "$(fFormatDate) | Creating Container..."
    $SAK = (Get-AzureRmStorageAccountKey -Name $StorageAccountName -ResourceGroupName $resourceGroup.ResourceGroupName).Value[0]
    $SAC = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $SAK

    $Container = New-AzureStorageContainer -Name $StorageAccountContainerName -Context $SAC

    if ($Container) {Write-Verbose "$(fFormatDate) | Storage Account $($StorageAccountContainerName) finished."}
    else {fErrorParameter -texto "Unexpected error."}
}

Write-Verbose "$(fFormatDate) | End of script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))"
