class AzLocks
{
    AzLocks( [object] $t)
    {
        $this.uriRestApi = "https://management.azure.com"
        $this.apiVersion = "api-version=2016-09-01"
        $this.Provider = "Microsoft.Authorization/locks" 
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

    hidden [object] executeInvoke ([string]$method, [string]$uriR, [object]$body) {
        try { return Invoke-RestMethod -Method $method -Uri $uriR -Headers $this.Headers -Body $(ConvertTo-Json $body -Depth 3) -ContentType 'application/json' }
        catch { return $null }
    }

    [object] GetLock ([string] $SubscriptionId) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/providers/$($this.Provider)?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }
    
    [object] GetLock ([string] $SubscriptionId, [string] $rgName) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/resourceGroups/$($rgName)/providers/$($this.Provider)?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }

    [object] GetLock ([string] $SubscriptionId, [string] $rgName, [string] $resourceName, [string] $resourceProvider ) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/resourceGroups/$($rgName)/providers/$($resourceProvider)/$($resourceName)/providers/$($this.Provider)?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }

    [object] GetLockById ([string] $resourceId) {
        $uriRequest = "$($this.uriRestApi)$($resourceId)/providers/$($this.Provider)?$($this.apiVersion)"
        return $this.executeInvoke("GET", $uriRequest)
    }

    [object] DeleteLock ([string] $SubscriptionId, [string] $LockName) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/providers/$($this.Provider)/$($LockName)?$($this.apiVersion)"
        return $this.executeInvoke("DELETE", $uriRequest)
    }
    
    [object] DeleteLock ([string] $SubscriptionId, [string] $rgName, [string] $LockName) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/resourceGroups/$($rgName)/providers/$($this.Provider)/$($LockName)?$($this.apiVersion)"
        return $this.executeInvoke("DELETE", $uriRequest)
    }

    [object] DeleteLock ([string] $SubscriptionId, [string] $rgName, [string] $resourceName, [string] $resourceProvider, [string] $LockName ) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/resourceGroups/$($rgName)/providers/$($resourceProvider)/$($resourceName)/providers/$($this.Provider)/$($LockName)?$($this.apiVersion)"
        return $this.executeInvoke("DELETE", $uriRequest)
    }

    [object] DeleteLockById ([string] $resourceId, [string] $LockName) {
        $uriRequest = "$($this.uriRestApi)$($resourceId)/providers/$($this.Provider)/$($LockName)?$($this.apiVersion)"
        return $this.executeInvoke("DELETE", $uriRequest)
    }

    [object] CreateLock ([string] $SubscriptionId, [string] $LockName, [string] $LockLevel, [string] $LockNotes) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/providers/$($this.Provider)/$($LockName)?$($this.apiVersion)"
        $lockBody=@{}
        $lockProperties=@{}
        $lockProperties.Add('level',$($LockLevel))
        $lockProperties.Add('notes',$($LockNotes))
        $lockBody.Add('properties',$lockProperties)
        return $this.executeInvoke("PUT", $uriRequest, $lockBody)
    }

    [object] CreateLock ([string] $SubscriptionId, [string] $rgName, [string] $LockName, [string] $LockLevel, [string] $LockNotes) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/resourceGroups/$($rgName)/providers/$($this.Provider)/$($LockName)?$($this.apiVersion)"
        $lockBody=@{}
        $lockProperties=@{}
        $lockProperties.Add('level',$($LockLevel))
        $lockProperties.Add('notes',$($LockNotes))
        $lockBody.Add('properties',$lockProperties)
        return $this.executeInvoke("PUT", $uriRequest, $lockBody)
    }

    [object] CreateLock ([string] $SubscriptionId, [string] $rgName, [string] $resourceName, [string] $resourceProvider, [string] $LockName, [string] $LockLevel, [string] $LockNotes ) {
        $uriRequest = "$($this.uriRestApi)/subscriptions/$($SubscriptionId)/resourceGroups/$($rgName)/providers/$($resourceProvider)/$($resourceName)/providers/$($this.Provider)/$($LockName)?$($this.apiVersion)"
        $lockBody=@{}
        $lockProperties=@{}
        $lockProperties.Add('level',$($LockLevel))
        $lockProperties.Add('notes',$($LockNotes))
        $lockBody.Add('properties',$lockProperties)
        return $this.executeInvoke("PUT", $uriRequest, $lockBody)
    }

    [object] CreateLockById ([string] $resourceId, [string] $LockName, [string] $LockLevel, [string] $LockNotes) {
        $uriRequest = "$($this.uriRestApi)$($resourceId)/providers/$($this.Provider)/$($LockName)?$($this.apiVersion)"
        $lockBody=@{}
        $lockProperties=@{}
        $lockProperties.Add('level',$($LockLevel))
        $lockProperties.Add('notes',$($LockNotes))
        $lockBody.Add('properties',$lockProperties)
        return $this.executeInvoke("PUT", $uriRequest, $lockBody)
    }

}
