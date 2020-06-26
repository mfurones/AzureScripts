<#
 .SYNOPSIS
    Allow to admin Networks Security Groups in Azure RM.

 .DESCRIPTION
    This script allows to import and export rules for a Network Security Group (or create a new NSG with rules.) in Azure RM. It can use the parameters to fill the command or use the interactive console to select or input data.

 .PARAMETER
 .-resourceGroupName
    Defines the Resource Group name.
    Variable type [string].
    Example: RG_Test

 .-NSGName
    Defines the Network Security Group Name.
    Variable type [string].
    Example: NSG-Test01
 
 .-CSV
    Defines the CSV file name (for default the name is: PS_ARM_NSGAdmin.csv).
    Variable type [string].
    Example: PS_ARM_NSGAdmin.csv

 .-accion
    Defines if "Export" rules to csv form NSG, "Import" rules to NSG from csv, "Create" a new NSG from csv rules.
    Variable type [string].
    Example: Export / Import / Create

 .-v or -Verbose
    Sets Verbose mode ON.

.EXAMPLE

    .\PS_ARM_NSGAdmin.ps1 -resourceGroupName RG_Test -NSGName NSG-Test01 -accion Export

    .\PS_ARM_NSGAdmin.ps1 -resourceGroupName RG_Test -NSGName NSG-Test01 -CSV fileNSGrules.csv -accion Import

#>

[CmdLetBinding()]
param(
 [string] $resourceGroupName,
 [string] $NSGName,
 [string] $CSV = "PS_ARM_NSGAdmin.csv",
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


<# Listar las Reglas del NSG #>

Function NSGExportSettingToFile {
    Param(
        [string] $RGN, #resourceGroupName
        [string] $NSGN, #nsgName
        [string] $file #CSV
    )
    Process
    {
        Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Searching Network Security Group...";
        $nsg = get-AzureRmNetworkSecurityGroup -Name $NSGN -ResourceGroupName $RGN -ErrorAction SilentlyContinue
        Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Exporting Network Security Group rules...";
        $nsg.SecurityRules | Select Name, Direction, Priority, SourceAddressPrefix, Protocol, SourcePortRange, DestinationAddressPrefix, DestinationPortRange, Access | export-csv $file
        Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Export Successful."
    }#Process
}#Function


<# Modificar las Reglas del NSG #>

Function NSGImportSettingFromFile {
    Param(
        [string] $RGN, #resourceGroupName
        [string] $NSGN, #nsgName
        [string] $file #CSV
    )
    Process
    {
        $nsgCSV = Import-Csv $file

        Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Searching Network Security Group...";
        $nsg = get-AzureRmNetworkSecurityGroup -Name $NSGN -ResourceGroupName $RGN -ErrorAction SilentlyContinue

        Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Actualising Network Security Group rules...";
        Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Cleaning Network Security Group rules...";
        $nsg.SecurityRules.Clear()

        Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Adding Network Security Group rules...";
        $nsgCSV | ForEach-Object {
            Add-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg -Name $_.Name -Direction $_.Direction -Priority $_.Priority -SourceAddressPrefix $_.SourceAddressPrefix -Protocol $_.Protocol -SourcePortRange $_.SourcePortRange -DestinationAddressPrefix $_.DestinationAddressPrefix -DestinationPortRange $_.DestinationPortRange -Access $_.Access | Out-Null
        }
        Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $nsg | Out-Null
        
        Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Finished Network Security Group: $($nsgName)";
    }
}


<# Crea el NSG y agrega las reglas #>

Function NSGCreateImportSettingFromFile {
    Param(
        [string] $RGN, #resourceGroupName
        [string] $RGL, #resourceGroupLocation
        [string] $NSGN, #nsgName
        [string] $file #CSV
    )
    Process
    {

        $nsgCSV = Import-Csv $file

        Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Searching Network Security Group...";
        $nsg = get-AzureRmNetworkSecurityGroup -Name $NSGN -ResourceGroupName $RGN -ErrorAction SilentlyContinue

        if(!$nsg){
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Setting Network Security Group...";
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Adding Network Security Group rules...";
            $nsgListRules = @()
            $nsgCSV | ForEach-Object {
                $nsgListRules += New-AzureRmNetworkSecurityRuleConfig -Name $_.Name -Direction $_.Direction -Priority $_.Priority -SourceAddressPrefix $_.SourceAddressPrefix -Protocol $_.Protocol -SourcePortRange $_.SourcePortRange -DestinationAddressPrefix $_.DestinationAddressPrefix -DestinationPortRange $_.DestinationPortRange -Access $_.Access
            }
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Creating Network Security Group...";
            $nsg = New-AzureRmNetworkSecurityGroup -Name $NSGN -ResourceGroupName $RGN -Location $RGL -SecurityRules $nsgListRules -WarningAction SilentlyContinue
        }
        else{
            Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | The Network Security Group [$($NSGN)] already exists.";
        }
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
    $pos = Read-Host "Enter N°"
    $resourceGroup = $TMP[$pos-1]
}


<# Accion #>

if($accion)
{
    $TMP = "Export", "Import", "Create"
    if($TMP.IndexOf($accion))
    {
        $NSGSwitch = $TMP.IndexOf($accion) +1
    }
    else
    {
        Write-host "$(Get-Date -UFormat "%d/%m/%Y") | $(Get-Date -Format T) | The action $($accion) doesn't exist." -ForegroundColor Red
        Write-host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | End of the Script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))";
        exit 1
    }
    $TMP = "Export", "Import", "Create"
    $NSGSwitch = $TMP.IndexOf($accion) +1
}
else
{
    write-host "Action on NSG."
    echo "------------------------------`n"
    Write-Host "1 - Export Rules"
    Write-Host "2 - Import Rules"
    Write-Host "3 - Create NSG & Import Rules"
    $NSGSwitch = Read-Host "Enter N°"
}

<# nsgName #>

if(!$nsgName)
{
    if($NSGSwitch -eq 3)
    {
        $nsgName = Read-Host -Prompt "Name of NSG"
    }
    else
    {
        $TMP = get-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
        Write-Host "List of Network Security Groups"
        echo "------------------------------"
        fEnumerateList -array $TMP | select Item,Name,ResourceGroupName | ft
        $pos = Read-Host "Enter N°"
        $nsgName = $TMP[$pos-1].Name
    }
}


<# Execute #>

switch ($NSGSwitch) 
    { 
        1 {
            NSGExportSettingToFile -RGN $resourceGroup.ResourceGroupName -NSGN $nsgName -file $CSV
        } # 1
        2 {
            NSGImportSettingFromFile -RGN $resourceGroup.ResourceGroupName  -NSGN $nsgName -file $CSV
        } # 2
        3 {
            NSGCreateImportSettingFromFile -RGN $resourceGroup.ResourceGroupName  -NSGN $nsgName -file $CSV -RGL $resourceGroup.Location
        } # 3
        default {"Opcion no determinada"}
    }

Write-Verbose "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | End of the Script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))";
