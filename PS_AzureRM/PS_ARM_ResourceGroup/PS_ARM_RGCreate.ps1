<#
 .SYNOPSIS
    Allow to create a Resource Group in Azure RM.

 .DESCRIPTION
    This script allows to create a Resource Group in Azure RM. It can use the parameters to fill the command or use the interactive console to select or input data.

 .PARAMETER
 .-resourceGroupName
    Defines the Resource Group name.
    Variable type [string].
    Example: RG_Test

 .-locationName
    Defines the Location name.
    Variable type [string].
    Example: eastus2

 .-v or -Verbose
    Sets Verbose mode ON.

.EXAMPLE

    .\PS_ARM_RGCreate.ps1 -resourceGroupName RG_Test -LocationName eastus2

#>


[CmdLetBinding()]
param(
 [string] $resourceGroupName,
 [string] $locationName

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

if (!$resourceGroupName)
{
    Write-Host "List of existing Resource Groups"
    echo "------------------------------"
    Get-AzureRmResourceGroup -ErrorAction SilentlyContinue | select Item,ResourceGroupName | ft
    $resourceGroupName = Read-Host "Enter RG Name"
}

$TMP = Get-AzureRmLocation

if ($locationName)
{
    $location = $TMP | Where-Object {$_.Location -eq $locationName}
    if (!$location)
    {
        Write-host "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | The Location $($resourceGroupName) is not correct." -ForegroundColor red
        exit 1
    }
}
else
{
    Write-Host "List of Location"
    echo "------------------------------"
    fEnumerateList -array $TMP | select Item,DisplayName,Location | ft
    $pos = Read-Host "Enter N°"
    $location = $TMP[$pos-1]
}

Write-Verbose "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | Searching Resource Group..."
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName  -ErrorAction SilentlyContinue

    if ($resourceGroup)
    {
        Write-host "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | The Resource Group $($resourceGroupName) already exists." -ForegroundColor Green
        exit 0
    }
    else
    {
        Write-Verbose "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | Creating Resource Group..."
        New-AzureRmResourceGroup -Name $resourceGroupName -Location $location.Location
    }

Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Finished Script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))";
