class AzureApiRest
{
    ApiRest( [object]$token, [string]$apiV )
    {
        $this.Subscription = [AzureSubscription]::new($token, "2020-01-01" )
        $this.ResourceGroup = [AzureResourceGroup]::new($token, "2019-10-01" )     
    }

    [object]$Subscription
    [object]$ResourceGroup



class ApiRest
{
    ApiRest( [object]$t, [string]$apiV )
    {
        $this.uriRestApi = "https://management.azure.com"
        $this.apiVersion = "api-version=$($apiV)"
        $this.Headers = @{
            'Content-Type' = 'application/json'
            'Authorization' = "$($t.token_type) $($t.access_token)"
        }       
    }

    hidden [string]$uriRestApi
    hidden [string]$apiVersion
    hidden [object]$Headers

    hidden [object] executeInvoke ([string]$method, [string]$uriR) {
        try { return Invoke-RestMethod -Method $method -Uri $uriR -Headers $this.Headers }
        catch { return $null }
}

class AzureSubscription : ApiRest 
{
    AzureSubscription( [object] $t, [string] $apiV ) : base($t, $apiV) {}

    [object] GetSubscription () {
        $uriRequest = "$($this.uriRestApi)/subscriptions?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }

    [object] GetSubscription ([string]$SubscriptionId) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }

}

class AzureResourceGroup : ApiRest 
{
    AzureResourceGroup( [object] $t, [string] $apiV ) : base($t, $apiV) {}

    [object] GetResourceGroup ([string]$SubscriptionId) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/resourcegroups?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }

    [object] GetResourceGroup ([string]$SubscriptionId, $ResourceGroupName) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/resourcegroups/$($ResourceGroupName)?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }

    [object] GetResourceGroupById ([string]$ResourceGroupId) {
        $uriRequest = "$($this.uriRestApi)$($ResourceGroupId)?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }

}

