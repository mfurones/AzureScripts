<#
 .SYNOPSIS
    Allow to make a copy Blob from an original.
    

 .DESCRIPTION
    This script allows to copy Blob from an original Blob in Azure RM.
    Allow to make a copy Blob to another Storage Account (and may stay in another subscription).
    It can use the parameters to fill the command or use the interactive console to select or input data.

 .PARAMETER
 .-resourceGroupOrigName
    Defines the Resource Group name for original Blob.
    Variable type [string].

 .-StorageAccountOrigName
    Defines the Storage Account name for original Blob.
    Variable type [string].
    Input: must be written in lowercase and numbers. Name must be between 3 and 23 characters.

 .-StorageAccountContainerOrigName
    Defines the Container name for original Blob.
    Variable type [string].

 .-BlobOrigName
    Defines the Blob name.
    Variable type [string].

 .-placeCopy
    Defines where is the Blob copied.
    Variable type [string].
    Example: Same | Another

.-subscriptionDestID
    Defines the Subscription ID for destination Blob.
    Variable type [string].

.-resourceGroupDestName
    Defines the Resource Group name for destination Blob.
    Variable type [string].

 .-StorageAccountDestName
    Defines the Storage Account name for destination Blob.
    Variable type [string].
    Input: must be written in lowercase and numbers. Name must be between 3 and 23 characters.

 .-StorageAccountContainerDestName
    Defines the Container name for destination Blob.
    Variable type [string].

 .-BlobDestName
    Defines the Blob destination name.
    Variable type [string].

 .-v or -Verbose
    Sets Verbose mode ON.

 .EXAMPLE

    .\PS_ARM_BlobCopy.ps1

    .\PS_ARM_BlobCopy.ps1 -resourceGroupOrigName RG-Demo -StorageAccountOrigName sademo01 -StorageAccountContainerOrigName vhds -BlobOrigName vm-demo.vhd -placeCopy Same

    .\PS_ARM_BlobCopy.ps1 -resourceGroupOrigName RG-Demo -StorageAccountOrigName sademo01 -StorageAccountContainerOrigName vhds -BlobOrigName vm-demo.vhd -placeCopy Another
                          -resourceGroupDestName RG-Test -StorageAccountDestName satest01 -StorageAccountContainerDestName vhds -BlobDestName vm-test.vhd
#>

[CmdLetBinding()]
param(
 [string] $resourceGroupOrigName,
 [string] $StorageAccountOrigName,
 [string] $StorageAccountContainerOrigName,
 [string] $BlobOrigName,

 [string] $placeCopy, #Same | Another

 [string] $subscriptionDestID,
 [string] $resourceGroupDestName,
 [string] $StorageAccountDestName,
 [string] $StorageAccountContainerDestName,
 [string] $BlobDestName
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


<# Subscription #>

$subscriptionOriginID = (Get-AzureRmContext).Subscription.SubscriptionId 


<# Resource Group #>

Write-Verbose "$(fFormatDate) | Searching Resource Group..."
if ($resourceGroupOrigName)
{
    $resourceGroupOrig = Get-AzureRmResourceGroup -Name $resourceGroupOrigName  -ErrorAction SilentlyContinue
    if (!$resourceGroupOrig) {fErrorParameter -texto "Definition error. Wrong name for Resource group."}
}
else
{
    $TMP = Get-AzureRmResourceGroup -ErrorAction SilentlyContinue
    Write-Host "List of Resource Groups"
    Write-Host "------------------------------"
    fEnumerateList -array $TMP | Select-Object Item,ResourceGroupName | Format-Table
    $pos = Read-Host "Enter N°"
    $resourceGroupOrig = $TMP[$pos-1]
}


<# Storage Account #>

Write-Verbose "$(fFormatDate) | Searching Storage Account..."
if ($StorageAccountOrigName)
{
    $StorageAccountOrig = Get-AzureRmStorageAccount -Name $StorageAccountOrigName -ResourceGroupName $resourceGroupOrig.ResourceGroupName  -ErrorAction SilentlyContinue
    if (!$StorageAccountOrig) {fErrorParameter -texto "Definition error. Wrong name for Storage Account."}
}
else
{
    $TMP = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupOrig.ResourceGroupName -ErrorAction SilentlyContinue
    Write-Host "List of Storage Account"
    Write-Host "------------------------------"
    fEnumerateList -array $TMP | Select-Object Item,StorageAccountName | Format-Table
    $pos = Read-Host "Enter N°"
    $StorageAccountOrig = $TMP[$pos-1]
}

<# Container #>
Write-Verbose "$(fFormatDate) | Searching Container..."

$SAKOrig = (Get-AzureRmStorageAccountKey -Name $StorageAccountOrig.StorageAccountName -ResourceGroupName $resourceGroupOrig.ResourceGroupName).Value[0]
$SACOrig = New-AzureStorageContext -StorageAccountName $StorageAccountOrig.StorageAccountName -StorageAccountKey $SAKOrig

if ($StorageAccountContainerOrigName)
{
    $ContainerOrig = get-AzureStorageContainer -Name $StorageAccountOrig.StorageAccountName -Context $SACOrig -ErrorAction SilentlyContinue
    if(!$ContainerOrig) {fErrorParameter -texto "Definition error. Wrong name for Container."}
}
else
{
    $TMP = get-AzureStorageContainer -Context $SACOrig -ErrorAction SilentlyContinue
    Write-Host "List of Containers"
    Write-Host "------------------------------"
    fEnumerateList -array $TMP | Select-Object Item,Name |Format-Table
    $pos = Read-Host "Enter N°"
    $ContainerOrig = $TMP[$pos-1]
}


<# Blob #>

Write-Verbose "$(fFormatDate) | Searching Blob..."

if ($BlobOrigName)
{
    $BlobOrig = Get-AzureStorageBlob -Context $SACOrig -Container $ContainerOrig.Name -Blob $BlobOrigName -ErrorAction SilentlyContinue
    if(!$BlobOrig) {fErrorParameter -texto "Definition error. Wrong name for Blob."}
}
else
{
    $TMP = Get-AzureStorageBlob -Context $SACOrig -Container $ContainerOrig.Name -ErrorAction SilentlyContinue
    if(!$TMP) {fErrorParameter -texto "Definition error. There's no Blobs available."}
    Write-Host "List of Blobs"
    Write-Host "------------------------------"
    fEnumerateList -array $TMP | Select-Object Item,Name | Format-Table
    $pos = Read-Host "Enter N°"
    $BlobOrig = $TMP[$pos-1]
}


<# Place Copy #>

$place = "same","another"
if($placeCopy) {fErrorParameter -texto "Definition error. The options for -placeCopy are: Same, Another."}
elseif (!($place.IndexOf($placeCopy) +1)) {fErrorParameter -texto "Definition error. The options for -placeCopy are: Same, Another."}

if ($placeCopy.ToLower() -eq $place[0])
{
    <# Same Place #>
    
    if (!$BlobDestName) {$BlobDestName = Read-Host "Enter destination Blob"}
    
    Write-Verbose "$(fFormatDate) | Searching Blob..."

    $blob2 = Get-AzureStorageBlob -Context $SACOrig -Container $ContainerOrig.Name -Blob $BlobDestName -ErrorAction SilentlyContinue
    if($blob2) {fErrorParameter -texto "Definition error. Destination Blob already exists."}
    
    Write-Verbose "$(fFormatDate) | Snaping Blob..."
    $snap = $BlobOrig.ICloudBlob.CreateSnapshot()
    Write-Verbose "$(fFormatDate) | Copy Snap..."
    $blobDest = Start-AzureStorageBlobCopy –Context $SACOrig -ICloudBlob $snap -DestBlob $BlobDestName -DestContainer $ContainerOrig.Name
    
    Write-Verbose "$(fFormatDate) | In Process..."
    DO
    {
        $TMP = $blobDest | Get-AzureStorageBlobCopyState 
        Start-Sleep 1
    } While($TMP.Status -eq "Pending")

    Write-Verbose "$(fFormatDate) | Deleting Snap..."
    $snap.delete()
}
elseif ($placeCopy.ToLower() -eq $place[1])
{
    <# Another Place #>

    <# subscriptionDestID #>

    Write-Verbose "$(fFormatDate) | Searching subscription..."
    if ($subscriptionDestID)
    {
        $subscriptionDest = Get-azurermsubscription -SubscriptionId $subscriptionDestID  -ErrorAction SilentlyContinue
        if(!$subscriptionDest) {fErrorParameter -texto "Wrong subscriptionDest."}
    }
    else
    {
        $TMP = Get-AzureRmSubscription -ErrorAction SilentlyContinue
        Write-Host "List of subscription"
        Write-Host "------------------------------"
        fEnumerateList -array $TMP | Select-Object Item,SubscriptionName,SubscriptionId | Format-Table
        $pos = Read-Host "Ingresar N°"
        $subscriptionDest = $TMP[$pos-1]
    }


    <# Resource Group Dest #>

    Write-Verbose "$(fFormatDate) | Searching Resource Group..."
    if ($resourceGroupDestName)
    {
        $resourceGroupDest = Get-AzureRmResourceGroup -Name $resourceGroupDestName  -ErrorAction SilentlyContinue
        if (!$resourceGroupDest) {fErrorParameter -texto "Definition error. Wrong name for Resource group."}
    }
    else
    {
        $TMP = Get-AzureRmResourceGroup -ErrorAction SilentlyContinue
        Write-Host "List of Resource Groups"
        Write-Host "------------------------------"
        fEnumerateList -array $TMP | Select-Object Item,ResourceGroupName | Format-Table
        $pos = Read-Host "Enter N°"
        $resourceGroupDest = $TMP[$pos-1]
    }


    <# Storage Account Dest #>

    Write-Verbose "$(fFormatDate) | Searching Storage Account..."
    if ($StorageAccountDestName)
    {
        $StorageAccountDest = Get-AzureRmStorageAccount -Name $StorageAccountDestName -ResourceGroupName $resourceGroupDest.ResourceGroupName  -ErrorAction SilentlyContinue
        if (!$StorageAccountDest) {fErrorParameter -texto "Definition error. Wrong name for Storage Account."}
    }
    else
    {
        $TMP = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupOrig.ResourceGroupName -ErrorAction SilentlyContinue
        Write-Host "List of Storage Account"
        Write-Host "------------------------------"
        fEnumerateList -array $TMP | Select-Object Item,StorageAccountName | Format-Table
        $pos = Read-Host "Enter N°"
        $StorageAccountDest = $TMP[$pos-1]
    }

    <# Container Dest #>
    Write-Verbose "$(fFormatDate) | Searching Container..."

    $SAKDest = (Get-AzureRmStorageAccountKey -Name $StorageAccountDest.StorageAccountName -ResourceGroupName $resourceGroupDest.ResourceGroupName).Value[0]
    $SACDest = New-AzureStorageContext -StorageAccountName $StorageAccountDest.StorageAccountName -StorageAccountKey $SAKDest

    if ($StorageAccountContainerDestName)
    {
        $ContainerDest = get-AzureStorageContainer -Name $StorageAccountDest.StorageAccountName -Context $SACDest -ErrorAction SilentlyContinue
        if(!$ContainerDest) {fErrorParameter -texto "Definition error. Wrong name for Container."}
    }
    else
    {
        $TMP = get-AzureStorageContainer -Context $SACDest -ErrorAction SilentlyContinue
        Write-Host "List of Containers"
        Write-Host "------------------------------"
        fEnumerateList -array $TMP | Select-Object Item,Name | Format-Table
        $pos = Read-Host "Enter N°"
        $ContainerDest = $TMP[$pos-1]
    }

    <# Blob Dest #>

    if (!$BlobDestName) {$BlobDestName = Read-Host "Enter destination Blob"}

    Write-Verbose "$(fFormatDate) | Searching Blob..."

    $blob2 = Get-AzureStorageBlob -Context $SACDest -Container $ContainerDest.Name -Blob $BlobDestName -ErrorAction SilentlyContinue
    if($blob2) {fErrorParameter -texto "Definition error. Destination Blob already exists."}

    Write-Verbose "$(fFormatDate) | Come back subscription..."
    select-azurermsubscription -SubscriptionId $subscriptionOriginID | Out-Null

    <# Temp Copy #>

    Write-Verbose "$(fFormatDate) | Temporary URL Disk..."
    $BlobTMPName = "temporalBlob.vhd"
    $BlobNameCopyUri = $ContainerOrig.CloudBlobContainer.StorageUri.PrimaryUri.AbsoluteUri + "/" + $BlobTMPName

    Write-Verbose "$(fFormatDate) | Snaping Blob..."
    $snap = $BlobOrig.ICloudBlob.CreateSnapshot()
    Write-Verbose "$(fFormatDate) | Copy Snap..."
    $blobTMP = Start-AzureStorageBlobCopy –Context $SACOrig -ICloudBlob $snap -DestBlob $BlobTMPName -DestContainer $ContainerOrig.Name
    
    Write-Verbose "$(fFormatDate) | In Progress..."
    DO
    {
        $TMP = $blobTMP | Get-AzureStorageBlobCopyState 
        Start-Sleep 1
    } While($TMP.Status -eq "Pending")


    Write-Verbose "$(fFormatDate) | Copying destination Disk..."
    $blobDest = Start-AzureStorageBlobCopy -srcUri $BlobNameCopyUri -SrcContext $SACOrig -DestContainer $ContainerDest.Name -DestBlob $BlobDestName -DestContext $SACDest

    Write-Verbose "$(fFormatDate) | In Progress..."
    DO
    {
        $TMP = $blobDest | Get-AzureStorageBlobCopyState 
        Start-Sleep 1
    } While($TMP.Status -eq "Pending")


    Write-Verbose "$(fFormatDate) | Deleting Snap..."
    $snap.delete()

    Write-Verbose "$(fFormatDate) | Deleting temporary disk..."
    Remove-AzureStorageBlob -Context $SACOrig -Container $ContainerOrig.Name -Blob $BlobTMPName

    Write-Verbose "$(fFormatDate) | End of copy..."
}
else {fErrorParameter -texto "Unexpected error."}

Write-Verbose "$(fFormatDate) | End of script. (Duración: $(("{0:hh\:mm\:ss}" -f ((Get-Date) - $currentTime))))"


