
class AzApiToken
{

    [object] GetToken([string] $TenantId, [string] $ClientId, [string] $ClientSecret ) {
        
        $RequestAccessTokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"
        $Resource = "https://management.core.windows.net/"
        $body = "grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret&resource=$Resource"
        try { $t = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'
        } catch { $t = $null }
        return $t
    }
}