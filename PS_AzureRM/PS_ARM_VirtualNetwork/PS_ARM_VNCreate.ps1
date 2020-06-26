<#
 .SYNOPSIS
    Allow to create a Virtual Network in Azure RM.

 .DESCRIPTION
    This script allows to create a Virtual Network in Azure RM. It can use the parameters to fill the command or use the interactive console to select or input data.

 .PARAMETER
 .-resourceGroupName
    Defines the Resource Group name.
    Variable type [string].
    Example: RG_Test

 .-virtualNetworkName
    Defines the Virtual Network name.
    Variable type [string].
    Example: VN-Test01
 
 .-AddressPrefix
    Defines the Virtual Network Space Address.
    Variable type [string].
    Example: 192.168.0.0/16

 .-SubnetName
    Defines the Subnet name.
    Variable type [string].
    Example: VN-Test01
 
 .-SubnetAddressPrefix
    Defines the Subnet Space Address.
    Variable type [string].
    Example: 192.168.0.0/24

 .-v or -Verbose
    Sets Verbose mode ON.

.EXAMPLE

    .\PS_ARM_VNCreate.ps1 -resourceGroupName RG_Test -virtualNetworkName VN-Test01 -AddressPrefix 192.168.0.0/16 -SubnetName LAN -SubnetAddressPrefix 192.168.0.0/16

#>

[CmdLetBinding()]
param(
 [string] $resourceGroupName,
 [string] $virtualNetworkName,
 [string] $AddressPrefix,
 [string] $SubnetName,
 [string] $SubnetAddressPrefix
)


<#
******************************************************************************
Funciones
******************************************************************************
#>

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
Write-Verbose "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | Starting Script..."

<# Resource Group #>

Write-Verbose "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | Searching Resource Group..."
if ($resourceGroupName)
{
    $resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName  -ErrorAction SilentlyContinue
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

<# Virtual Network #>

if(!$virtualNetworkName)
{
    $virtualNetworkName = Read-Host "Insert the Virtual Network Name"
}

if(!$AddressPrefix)
{
    $tmp = Read-Host "Insert the Adrress Prefix or press [enter] for default [192.168.0.0/16]"
    if ($tmp -eq "") {$AddressPrefix = "192.168.0.0/16"}
    else {$AddressPrefix = $tmp}
}

Write-Verbose "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | Searching for existing Virtual Network..."
$virtualNetwork = get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup.ResourceGroupName -Name $virtualNetworkName -ErrorAction SilentlyContinue
if ($virtualNetwork)
{
    Write-host "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | The Virtual Network $($virtualNetworkName) does exist." -ForegroundColor Red
    Write-host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | End of the Script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))";
    exit 1
}

<# Subnet #>

if(!$SubnetName)
{
    $SubnetName = Read-Host "Insert the Subnet name or press [enter] for default [LAN]"
    if ($tmp -eq "") {$SubnetName = "LAN"}
    else {$SubnetName = $tmp}
}

if(!$SubnetAddressPrefix)
{
    $SubnetAddressPrefix = Read-Host "Insert the Subnet Address Prefix (Space Address: $($AddressPrefix))"
}

Write-Verbose "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | Creating a Virtual Network Subnet..."
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
Write-Verbose "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | Creating the Virtual Network..."
$virtualNetwork = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup.ResourceGroupName -Name $virtualNetworkName -AddressPrefix $AddressPrefix -Location $resourceGroup.Location -Subnet $subnetConfig

Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Finished deployment. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))";

