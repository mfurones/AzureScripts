### Consumption ###
class AzNetwork
{
    AzNetwork([object] $token)
    {
        $this.VirtualNetwork = [AzureBase]::new($token, "Microsoft.Network/virtualNetworks", "2020-01-01" )
        $this.VirtualNetworkPeering = [AzureVnetPeering]::new($token, "Microsoft.Network/virtualNetworks", "2020-04-01" )
        $this.VirtualHub = [AzureBase]::new($token, "Microsoft.Network/virtualHubs", "2020-04-01" )
    }
    [AzureBase]$VirtualNetwork
    [AzureVnetPeering]$VirtualNetworkPeering
    [AzureBase]$VirtualHub
}

### Generic ###
class ApiRest
{
    ApiRest( [object]$t, [string]$Prov, [string]$apiV )
    {
        $this.uriRestApi = "https://management.azure.com"
        $this.apiVersion = "api-version=$($apiV)"
        $this.Provider = $Prov 
        $this.Headers = @{
            'Content-Type' = 'application/json'
            'Authorization' = "$($t.token_type) $($t.access_token)"
        }       
    }

    hidden [string]$uriRestApi
    hidden [string]$apiVersion
    hidden [string]$Provider
    hidden [object]$Headers

    hidden [object] executeInvoke ([string]$method, [string]$uriR) {
        try { return Invoke-RestMethod -Method $method -Uri $uriR -Headers $this.Headers }
        catch { return $null }
    }
}

<### Generic ###
 VirtualNetwork
 VirtualHub
#>
class AzureBase : ApiRest 
{
    AzureBase( [object] $t, [string] $Prov, [string] $apiV ) : base($t, $Prov, $apiV) {}

    [object] GetResource ([string]$SubscriptionId) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/providers/$($this.Provider)?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }

    [object] GetResource ([string] $SubscriptionId, [string] $rgName) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/resourceGroups/$($rgName)/providers/$($this.Provider)?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }

    [object] GetResource ([string] $SubscriptionId, [string] $rgName, [string] $resourceName) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/resourceGroups/$($rgName)/providers/$($this.Provider)/$($resourceName)?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }

    [object] GetResourceById ([string] $resourceId) {
        $uriRequest = "$($this.uriRestApi)$($resourceId)?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }


}

### Virtual Peering ###
class AzureVnetPeering : ApiRest 
{
    AzureVnetPeering([object]$t, [string]$Prov, [string]$apiV) : base($t, $Prov, $apiV) {}

    [object] DeleteResource ([string] $SubscriptionId, [string] $rgName, [string] $resourceName, [string] $peeringName) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/resourceGroups/$($rgName)/providers/$($this.Provider)/$($resourceName)/virtualNetworkPeerings/$($peeringName)?$($this.apiVersion)"
        return $this.executeInvoke("DELETE", $uriRequest)
    }

    [object] DeleteResourceById ([string] $resourceId, [string] $peeringName) {
        $uriRequest = "$($this.uriRestApi)$($resourceId)/virtualNetworkPeerings/$($peeringName)?$($this.apiVersion)"
        return $this.executeInvoke("DELETE", $uriRequest)
    }


}



