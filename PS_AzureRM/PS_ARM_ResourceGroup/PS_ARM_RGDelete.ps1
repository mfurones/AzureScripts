<#
 .SYNOPSIS
    Allow to delete a Resource Group in Azure RM.

 .DESCRIPTION
    This script allows to delete a Resource Group in Azure RM. It can use the parameters to fill the command or use the interactive console to select or input data.

 .PARAMETER
 .-resourceGroupName
    Defines the Resource Group name.
    Variable type [string].
    Example: RG_Test

 .-v or -Verbose
    Sets Verbose mode ON.

.EXAMPLE

    .\PS_ARM_RGDelete.ps1 -resourceGroupName RG_Test

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
    fEnumerateList -array $TMP | select Item,ResourceGroupName | ft
    $pos = Read-Host "Enter N°"
    $resourceGroup = $TMP[$pos-1]
}


if ($resourceGroup)
    {
        Write-Verbose "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | Deleting Resource Group..."
        Remove-AzureRmResourceGroup -Id $resourceGroup.ResourceId -Force
    }
    else
    {
        Write-host "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | The Resource Group $($resourceGroupName) doesn't exists." -ForegroundColor red
        exit 1
    }

Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Finished Script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))";
