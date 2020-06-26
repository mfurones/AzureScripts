<#
 .SYNOPSIS
    Allow to delete Resources in Azure RM.

 .DESCRIPTION
    This script allows to delete Resources in Azure RM.

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
param(
 [string] $resourceGroupName

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
    fEnumerateList -array $TMP | select Item,ResourceGroupName,Location | ft
    $pos = Read-Host "Ingresar N°"
    $resourceGroup = $TMP[$pos-1]
}

<# Select Resources #>

$resources = Find-AzureRmResource -ResourceGroupNameContains $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
if ($resources)
{
    Write-Host "List of Resource Groups"
    echo "------------------------------"
    fEnumerateList -array $resources | select Item,Name,ResourceGroupName,Location | ft
    $pos = Read-Host "Ingresar N°"
    $items = $pos.Split("{,}")
}
else
{
    Write-host "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | There are not Resources." -ForegroundColor Red
    Write-host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | End of the Script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))";
    exit 1
}

<# Remove Resources #>

$items | ForEach-Object {
    Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Removing resource $($resources[$_ - 1].Name)..."
    # Se borra mediante el id
    Remove-AzureRmResource -ResourceId $resources[$_ - 1].ResourceId -Force | Out-Null
}

Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | End of the Script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))";
