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

 .-vmName
    Defines the Virtual Machine Name.
    Variable type [string].
    Example: VM-Test01
 
 .-accion
    Defines if Start or Stop the Virtual Machine.
    Variable type [string].
    Example: 192.168.0.0/16

 .-v or -Verbose
    Sets Verbose mode ON.

.EXAMPLE

    .\PS_ARM_VMStartStop.ps1 -resourceGroupName RG_Test -vmName VM-Test01 -accion Start

    .\PS_ARM_VMStartStop.ps1 -resourceGroupName RG_Test -vmName VM-Test01 -accion Stop

#>

[CmdLetBinding()]
param(
 [string] $resourceGroupName,
 [string] $vmName,
 [string] $accion
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

<# Virtual Machine #>

Write-Verbose "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | Searching Virtual Machine..."
if ($vmName)
{
    $virtualMachine = Get-AzureRmvm -Name $vmName -resourceGroupName $resourceGroup.ResourceGroupName  -ErrorAction SilentlyContinue
}
else
{
    $TMP = Get-AzureRmvm -resourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
    Write-Host "List of Virtual Machines"
    echo "------------------------------"
    fEnumerateList -array $TMP | select Item,Name,ResourceGroupName,Location | ft
    $pos = Read-Host "Ingresar N°"
    $virtualMachine = $TMP[$pos-1]
}

<# Action #>

if(!$accion)
{
    $TMP = "Start", "Stop", "Restart"
    write-host "Action on the Virtual Machine."
    echo "------------------------------`n"
    Write-Host "1 - Start"
    Write-Host "2 - Stop"
    Write-Host "3 - Restart"
    $pos = Read-Host "Ingresar N°"
    $accion = $TMP[$pos-1]
}


<# Script #>

if ($virtualMachine)
{
    # Buscamos el estado
    $vmStatus = Get-AzureRmVM -ResourceGroupName $resourceGroup.ResourceGroupName -Name $virtualMachine.Name -Status -ErrorAction SilentlyContinue
    $vmStatuses = ($vmStatus.Statuses | where Code -like "PowerState*").Code

    if ($accion -eq "Start")
    {
        if (($vmStatuses -match "deallocated"))
        {
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Starting VM...";
            # Encendido de la VM
            Start-AzureRmVM -ResourceGroupName $resourceGroup.ResourceGroupName -Name $virtualMachine.Name
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | VM started.";
        }
        else
        {
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | The VM is already: $($vmStatuses).";
        }
    }
    elseif ($accion -eq "Stop")
    {
        if (($vmStatuses -match "running"))
        {
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Stopping VM...";
            # Apagado de la VM
            Stop-AzureRmVM -ResourceGroupName $resourceGroup.ResourceGroupName -Name $virtualMachine.Name -Force
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | VM stopped.";
        }
        else
        {
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | The VM is already: $($vmStatuses).";
        }
    }
    elseif ($accion -eq "Restart")
    {
        if (($vmStatuses -match "running"))
        {
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Restarting VM...";
            # Apagado de la VM
            Restart-AzureRmVM -ResourceGroupName $resourceGroup.ResourceGroupName -Name $virtualMachine.Name
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | VM restarted.";
        }
        else
        {
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | The VM is already: $($vmStatuses).";
        }
    }
    else
    {
        Write-host "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | The action $($accion) doesn't exist." -ForegroundColor Red
        Write-host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | End of the Script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))";
        exit 1
    }

    
}
else
{
    # La VM no existe
    Write-host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Recurso inexistente: $($vmName)" -ForegroundColor Red;
    Write-host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | End of the Script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))";
    exit 1
}

Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | End of the Script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))";
