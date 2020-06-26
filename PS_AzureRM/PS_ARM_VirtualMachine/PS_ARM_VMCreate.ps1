<#
 .SYNOPSIS
    Allow to create a Virtual Machine.

 .DESCRIPTION
    This script allows to create a Virtual Machine. It can use the parameters to fill the command or use the interactive console to select or input data.

 .PRE-REQUISITES
    - Mandatory:
        - Existing Resosurce Group.
        - Existing Virtual Machine.
        - Existing Storage Account (unmanaged disk).
    - No Mandatory:
        - Existing Availability Set
    
 .PARAMETER
 .-resourceGroupName
    Defines the resource group name.
    Variable type [string].

 .-vmName
    Defines the virtual machine Name.
    Variable type [string].

 .-vmIsLinux
    Defines the virtual machine Type OS (Linux | Windows).
    Variable type [string]
    Example: True (Linux) | False (Windows).

 .-vmSize
    Defines the virtual machine plan.
    Variable type [string].
    Example: "Standard_A4_v2"

 .-vmPublisher
    Defines the virtual achine publisher.
    Variable type [string].
    Example: "OpenLogic"

 .-vmOffer
    Defines the virtual machine offer.
    Variable type [string].
    Example: "CentOS" (Publisher: "OpenLogic")

 .-vmSku
    Defines the virtual machine sku.
    Variable type [string].
    Example: "7.3" (Publisher: "OpenLogic", Offer: "CentOS")

 .-vmVersion
    Defines the virtual machine version.
    Variable type [string].
    Example: "7.3" (Publisher: "OpenLogic", Offer: "CentOS", Sku: "7.3")

 .-BootDiagnosticsEnable
    Defines the enabling of the BootDiagnostics in the virtual machine.
    Variable type [string].
    Examble: True (enable) | False (disable)

 .-AvailabilitySetName
    Defines the AvailabilitySet name.
    Variable type [string].

 .-VirtualNetworkName
    Defines the virtual network name.
    Variable type [string].

 .-VirtualNetworkSubnetName
    Defines the virtual network Subnet name.
    Variable type [string].

 .-StorageAccountName
    Defines the storage account name.
    Variable type [string].

 .-StorageAccountContainerName
    Defines the storage account Container name.
    Variable type [string].

 .-BlobOSName
    Defines the Blob OS name.
    Variable type [string].

 .-NetworkInterfaceCardName
    Defines the Network Interface Card name.
    Variable type [string].

 .-PublicIPName
    Defines the Public IP name.
    Variable type [string].

 .-NetworkSecurityGroupName
    Defines the Network Security Group name.
    Variable type [string].
    
.EXAMPLE

    .\PS_ARM_VMCreate.ps1 -resourceGroupName 'RG-Demo' -vmName 'VM-Demo-01'

    .\PS_ARM_VMCreate.ps1 -resourceGroupName 'RG-Demo' -vmName 'VM-Demo-01' -vmIsLinux True -vmSize 'Standard_A2_v2' `                            -vmPublisher 'OpenLogic' -vmOffer 'CentOS' -vmSku '7.3' -vmVersion 'latest' `                            -VirtualNetworkName 'VN_demo' -VirtualNetworkSubnetName 'SN-demo' `                            -StorageAccountName 'sademotmp' -StorageAccountContainerName 'vhds' -BlobOSName 'VM-demo01.vhd'
                            -NetworkInterfaceCardName 'NIC-demo' -PublicIPName 'PIP-demo' -NetworkSecurityGroupName 'NSG-demo'

#>


param(

 [string] $resourceGroupName,

 [string] $vmName,
 
 [string] $vmIsLinux,
 [string] $vmSize,

 [string] $vmPublisher,
 [string] $vmOffer,
 [string] $vmSku,
 [string] $vmVersion,
 [string] $vmUSR,
 [string] $vmPASS,

 [string] $BootDiagnosticsEnable,

 [string] $AvailabilitySetName,

 [string] $VirtualNetworkName,
 [string] $VirtualNetworkSubnetName,

 [string] $StorageAccountName,
 [string] $StorageAccountContainerName = "vhds",
 
 [string] $BlobOSName,

 [string] $NetworkInterfaceCardName,

 [string] $PublicIPName,

 [string] $NetworkSecurityGroupName
 
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

# Storage Account Context
Function fStorageAccountContext {
    Param(
    [string] $SAN, #StorageAccountName
    [string] $RGN #ResourceGroupName
    )#param

    Process
    {
        $SAK = (Get-AzureRmStorageAccountKey -Name $SAN -ResourceGroupName $RGN).Value[0]
        $SAC = New-AzureStorageContext -StorageAccountName $SAN -StorageAccountKey $SAK
        return $SAC
    }#process
}

# Storage Account Container
Function fStorageAccountContainer {
    Param(
    [string] $SACN, #StorageAccountContainerName
    [object] $SAC, #StorageAccountContext
    [string] $RGN #ResourceGroupName
    )#param

    Process
    {
        # verificacion de existencia y creacion de container
        $SAContainer = get-AzureStorageContainer -Context $SAC -Name $SACN -ErrorAction SilentlyContinue
        if(!$SAContainer){ New-AzureStorageContainer -Name $SACN -Context $SAC }
    }#process
}


<# Script #>

$currentTime = (Get-Date)

# Name of the VM
if(!$vmName)
{
    $vmName = Read-Host "Ingresar nombre de la nueva VM"
}

# Resource Group

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
    $pos = Read-Host "Ingresar N°"
    $resourceGroup = $TMP[$pos-1]
}


# Availability Set

if($AvailabilitySetName)
{
    $AvailabilitySet = Get-AzureRmAvailabilitySet -Name $AvailabilitySetName -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
}
else
{
    $TMP = $true, $false
    write-host "Availability Set Enable.`n"
    $pos = Read-Host "Ingresar N°: 1 - True | 2 - False"
    $AvailabilitySetEnable = $TMP[$pos-1]
    if($AvailabilitySetEnable)
    {
        $TMP = Get-AzureRmAvailabilitySet -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
        Write-Host "List of Availability Set"
        echo "------------------------------"
        fEnumerateList -array $TMP | select Item,Name,ResourceGroupName | ft
        $pos = Read-Host "Ingresar N°"
        $AvailabilitySet = $TMP[$pos-1]
    }
}



# Virtual Network

if($VirtualNetworkName)
{
    $VirtualNetwork = Get-AzureRmVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
}
else
{
    $TMP = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
    Write-Host "List of Virtual Networks"
    echo "------------------------------"
    fEnumerateList -array $TMP | select Item,Name,ResourceGroupName | ft
    $pos = Read-Host "Ingresar N°"
    $VirtualNetwork = $TMP[$pos-1]
}


# Storage Account

if($StorageAccountName)
{
    $StorageAccount = Get-AzureRmStorageAccount -AccountName $StorageAccountName -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
}
else
{
    $TMP = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
    Write-Host "List of Storages Accounts"
    echo "------------------------------"
    fEnumerateList -array $TMP | select Item,StorageAccountName,ResourceGroupName | ft
    $pos = Read-Host "Ingresar N°"
    $StorageAccount = $TMP[$pos-1]
}

# Storage Account Context
$StorageAccountContext = fStorageAccountContext -SAN $StorageAccount.StorageAccountName -RGN $ResourceGroup.ResourceGroupName

# Storage Account Container
fStorageAccountContainer -SACN $StorageAccountContainerName -SAC $StorageAccountContext -RGN $ResourceGroup.ResourceGroupName


# Network Interface Card

if ($NetworkInterfaceCardName)
{
    $NetworkInterfaceCard = Get-AzureRMNetworkInterface -Name $NetworkInterfaceCardName -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
}
else
{
    $TMP = Get-AzureRMNetworkInterface -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
    if($TMP)
    {
        Write-Host "List of Network Interface Cards"
        echo "------------------------------"
        fEnumerateList -array $TMP | select Item,Name,ResourceGroupName | ft
        $pos = Read-Host "Ingresar N° | Press [Enter] for automating name | Write the new name for the NIC"
    }
    else{$pos = Read-Host "Press [Enter] for automating name | Write the new name for the NIC"}
    if($pos -match "^[\d\.]+$"){$NetworkInterfaceCard = $TMP[$pos-1]}
    elseif($pos -eq "") {$NetworkInterfaceCardName = "NIC-$($vmName)"}
    else{$NetworkInterfaceCardName = $pos}
}

if(!$NetworkInterfaceCard)
{

    <# Public IP #>

    if($PublicIPName)
    {
        $PublicIP = Get-AzureRmPublicIpAddress -Name $PublicIPName -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
    }
    else
    {
        $TMP = Get-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
        if($TMP)
        {
            Write-Host "List of Public IPs"
            echo "------------------------------"
            fEnumerateList -array $TMP | select Item,Name,ResourceGroupName | ft
            $pos = Read-Host "Ingresar N° | Press [Enter] for automating name | Write the new name for the PIP"
        }
        else {$pos = Read-Host "Press [Enter] for automating name | Write the new name for the PIP"}
        if($pos -match "^[\d\.]+$") {$PublicIP = $TMP[$pos-1]}
        elseif($pos -eq "") {$PublicIPName = "PIP-$($vmName)"}
        else {$PublicIPName = $pos}
    }

    if(!$PublicIP)
    {
        $regex = "[a-zA-Z0-9]"
        foreach($i in Select-String -InputObject $vmName -Pattern $regex -AllMatches | %{$_.Matches} | %{$_.Value}) {$DomainNameLabel += $i.ToLower()}
        $PublicIP = New-AzureRmPublicIpAddress -Name $PublicIPName -DomainNameLabel $DomainNameLabel -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -AllocationMethod Dynamic
    }


    <# Network Security Group #>

    if($NetworkSecurityGroupName)
    {
        $NetworkSecurityGroup = Get-AzureRmNetworkSecurityGroup -Name $NetworkSecurityGroupName -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
    }
    else
    {
        $TMP = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
        if($TMP)
        {
            Write-Host "List of Network Security Group"
            echo "------------------------------"
            fEnumerateList -array $TMP | select Item,Name,ResourceGroupName | ft
            $pos = Read-Host "Ingresar N° | Press [Enter] for automating name | Write the new name for the NSG"
        }
        else {$pos = Read-Host "Press [Enter] for automating name | Write the new name for the NSG"}        
        if($pos -match "^[\d\.]+$") {$NetworkSecurityGroup = $TMP[$pos-1]}
        elseif($pos -eq "") {$NetworkSecurityGroupName = "NSG-$($vmName)"}
        else {$NetworkSecurityGroupName = $pos}
    }

    if(!$NetworkSecurityGroup)
    {
        $nsgDirection = 'Inbound'
        $nsgRulesName = 'Allow-Conection'
        $nsgPriority = 1000
        $nsgSourceAddressPrefix = '*'
        $nsgProtocol = 'Tcp'
        $nsgSourcePortRange = '*'
        $nsgDestinationAddressPrefix = '*'
        $nsgAccess = 'Allow'
        if($vmtype){ $nsgRulesDestinationPortRange = 22}
        else{$nsgRulesDestinationPortRange = 3389}
        $NSGRules = New-AzureRmNetworkSecurityRuleConfig -Name $nsgRulesName -Direction $nsgDirection -Priority $nsgPriority -Access $nsgAccess -SourceAddressPrefix $nsgSourceAddressPrefix -SourcePortRange $nsgSourcePortRange -DestinationAddressPrefix $nsgDestinationAddressPrefix -DestinationPortRange $nsgRulesDestinationPortRange -Protocol $nsgProtocol
        $NetworkSecurityGroup = New-AzureRmNetworkSecurityGroup -Name $NetworkSecurityGroupName -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -SecurityRules $NSGRules
    }


    <# Create NIC #>
    Write-Host "Seleccionar SubNet de la VN: $($VirtualNetwork.Name)"
    echo "------------------------------"
    fEnumerateList -array $VirtualNetwork.Subnets | select Item,Name | ft
    $pos = Read-Host "Ingresar N°"
    $VNSNN = $VirtualNetwork.Subnets[$pos-1].Name
    $NetworkInterfaceCard = New-AzureRMNetworkInterface -Name $NetworkInterfaceCardName -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -SubnetId $VirtualNetwork.Subnets.Where({$_.Name -eq $VNSNN }).id -NetworkSecurityGroupId $NetworkSecurityGroup.Id -PublicIpAddressId $PublicIP.Id
}


<# Parameters Virtual Machine #>

# Size of the VM
if(!$vmSize)
{
    $TMP = Get-AzureRmVMSize -Location $resourceGroup.Location -ErrorAction SilentlyContinue
    Write-Host "List of VM Plans"
    echo "------------------------------"
    fEnumerateList -array $TMP | select Item,Name,NumberOfCores,MemoryInMB,MaxDataDiskCount | ft
    $pos = Read-Host "Ingresar N°"
    $vmSize = $TMP[$pos-1].Name
}

# BootDiagnosticsEnable
if(!$BootDiagnosticsEnable)
{
    $TMP = "True", "False"
    write-host "Boot Diagnostics Enable."
    echo "------------------------------`n"
    $pos = Read-Host "Ingresar N°: 1 - True | 2 - False"
    $BootDiagnosticsEnable = $TMP[$pos-1]
}


# OS Blob of the VM 
if($BlobOSName)
{
    $BlobOS = Get-AzureStorageBlob -Context $StorageAccountContext -Container $StorageAccountContainerName -Blob $BlobOSName -ErrorAction SilentlyContinue
}
else
{
    $TMP = Get-AzureStorageBlob -Context $StorageAccountContext -Container $StorageAccountContainerName -ErrorAction SilentlyContinue
    Write-Host "Nombre del Virtual Disk (vhd). (Nombre VM: $($vmName))"
    if($TMP)
    {
        echo "------------------------------"
        fEnumerateList -array $TMP | select Item,Name,ICloudBlob | ft
        $pos = Read-Host "Ingresar N° | Press [Enter] for automating name | Write the custom name"
    }
    else {$pos = Read-Host "Press [Enter] for automating name | Write the custom name"}    
    if($pos -match "^[\d\.]+$"){$BlobOS = $TMP[$pos-1]}
    elseif (($pos -eq "") -or ($pos -eq "y")){$BlobOSName = "$($vmName).vhd"}
    else{$BlobOSName = $pos}
}

# Type of OS
if(!$vmIsLinux)
{
    $TMP = "True", "False"
    write-host "Select the OS."
    echo "------------------------------`n"
    $pos = Read-Host "Ingresar N°: 1 - Linux | 2 - Windows"
    $vmIsLinux = $TMP[$pos-1]
}

<# Parametros de nueva Imagen #>

if(!$BlobOS)
{
    if(!$vmUSR){$vmUSR = Read-Host "Ingresar nombre del usuario"}
    if(!$vmPASS){$vmPASS = Read-Host "Ingresar password"}
    if(!$vmPublisher)
    {
        $TMP = Get-AzureRmVMImagePublisher -Location $resourceGroup.Location
        Write-Host "List of Publishers"
        echo "------------------------------"
        fEnumerateList -array $TMP | select Item,PublisherName, Location | ft
        $pos = Read-Host "Ingresar N°"
        $vmPublisher = $TMP[$pos-1].PublisherName
    }
    if(!$vmOffer)
    {
        $TMP = Get-AzureRmVMImageOffer -Location $resourceGroup.Location -PublisherName $vmPublisher
        Write-Host "List of Image"
        echo "------------------------------"
        fEnumerateList -array $TMP | select Item, Offer, PublisherName, Location | ft
        $pos = Read-Host "Ingresar N°"
        $vmOffer = $TMP[$pos-1].Offer
    }
    if(!$vmSku)
    {
        $TMP = Get-AzureRmVMImageSku -Location $resourceGroup.Location -PublisherName $vmPublisher -Offer $vmOffer
        Write-Host "List of Sku"
        echo "------------------------------"
        fEnumerateList -array $TMP | select Item, Skus, Offer, PublisherName, Location | ft
        $pos = Read-Host "Ingresar N°"
        $vmSku = $TMP[$pos-1].Skus
    }
    if(!$vmVersion)
    {
        $TMP = Get-AzureRmVMImage -Location $resourceGroup.Location -PublisherName $vmPublisher -Offer $vmOffer -Skus $vmSku
        Write-Host "List of Version"
        echo "------------------------------"
        fEnumerateList -array $TMP | select Item, Version, Skus, Offer, PublisherName, Location | ft
        $pos = Read-Host "Ingresar N° | Press [Enter] for last Version"
        if($pos -match "^[\d\.]+$"){$vmVersion = $TMP[$pos-1].Version}
        else{$vmVersion = "latest"}
    }
}


<# Virtual Machine #>

# Crea una Configuracion de VM
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

# Configuracion del Availability Set
if($AvailabilitySet)
{$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $AvailabilitySet.Id}

# Configuracion del boot diagnostic
if ($BootDiagnosticsEnable -eq "True")
{Set-AzureRmVMBootDiagnostics -VM $vmConfig -ResourceGroupName $resourceGroup.ResourceGroupName -StorageAccountName $StorageAccount.StorageAccountName  -Enable | Out-Null}
else
{Set-AzureRmVMBootDiagnostics -VM $vmConfig -Disable | Out-Null}

# Configuracion del disco del sistema operativo
if($BlobOS)
{
    if($vmIsLinux -eq "True")
    {$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name $BlobOS.Name -VhdUri $BlobOS.ICloudBlob.uri.AbsoluteUri -CreateOption Attach -Linux}
    else
    {$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name $BlobOS.Name -VhdUri $BlobOS.ICloudBlob.uri.AbsoluteUri -CreateOption Attach -Windows}
}
else{
    $vmPassword = ConvertTo-SecureString $vmPASS -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($vmUSR, $vmPassword)
    $osVhdUri = "$($storageAccount.PrimaryEndpoints.Blob.ToString())$($StorageAccountContainerName)/$($BlobOSName)"
    if($vmIsLinux -eq "True")
    {
        $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName -Credential $cred
        $vmConfig = Set-AzureRmVMSourceImage -VM $vmConfig -PublisherName $vmPublisher -Offer $vmOffer -Skus $vmSku -Version $vmVersion
        $vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name $BlobOSName -VhdUri $osVhdUri -CreateOption fromImage -Linux
    }
    else
    {
        $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $cred
        $vmConfig = Set-AzureRmVMSourceImage -VM $vmConfig -PublisherName $vmPublisher -Offer $vmOffer -Skus $vmSku -Version $vmVersion
        $vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name $BlobOSName -VhdUri $osVhdUri -CreateOption fromImage -Windows
    }

}


# Configuracion del Network interface card
$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $NetworkInterfaceCard.Id -Primary

# Generacion de la VM
Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Start VM deployment...";
New-AzureRmVM -VM $vmConfig -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location

# End the deployment
Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Finished deployment. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))";
Start-Sleep -Seconds 1





