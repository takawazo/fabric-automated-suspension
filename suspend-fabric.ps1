Param(
    [string[]]$ResourceIDs, # e.g. "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Fabric/capacities/xxxx"
    [ValidateSet("suspend")] # Only allow "suspend" for now
    [string]$operation
)
# Reference
# https://learn.microsoft.com/en-us/fabric/enterprise/pause-resume

# Get access token
# There will be breaking change in Az module 14.0.0, so we need to use Get-AzAccessToken instead of Get-AzAccessToken -ResourceUrl "https://management.azure.com/"
# https://learn.microsoft.com/en-us/powershell/azure/migrate-az-14.0.0?view=azps-14.1.0

$ResourceIDs = @(
# resource ID for fabric capacity
)
$operation = "suspend"

# Connect using Managed Identity (uncomment if needed)
# Connect-AzAccount -Identity

# Get the access token securely
# Using Get-AzAccessToken with -AsSecureString to ensure compatibility with older environments
try {
    $secureToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com/" -AsSecureString).Token
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
    $token = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
} catch {
    # Fallback for older environments
    $token = (Get-AzAccessToken -ResourceUrl "https://management.azure.com/").Token
}

# Use the token in headers
$headers = @{
    'Content-Type'  = 'application/json'
    'Authorization' = "Bearer $token"
}

# Validate operation
if ($operation -eq "suspend") {
    foreach ($ResourceID in $ResourceIDs) {
        $url = "https://management.azure.com$ResourceID" + "/" + $operation + "?api-version=2023-11-01"
        Write-Output "Calling: $url"

        try {
            $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -ErrorAction Stop

            if ($null -eq $response) {
                Write-Output "✅ [$operation] succeeded for: $ResourceID (no response body)"
            } else {
                Write-Output "✅ [$operation] succeeded for: $ResourceID"
                $response | ConvertTo-Json -Depth 5 | Write-Output
            }

        } catch {
            $rawMessage = $_.ToString()

            try {
                $errorJson = $rawMessage | ConvertFrom-Json
                $message = $errorJson.error.message

                if ($message -like "*Service is not ready to be updated*") {
                    Write-Output "ℹ️ [$operation] skipped for: $ResourceID"
                    Write-Output "  • Reason: Capacity is not running (already stopped or not ready)"
                } else {
                    Write-Output "❌ [$operation] failed for: $ResourceID"
                    Write-Output "  • Error Code       : $($errorJson.error.code)"
                    Write-Output "  • Message          : $message"
                    Write-Output "  • SubCode          : $($errorJson.error.subCode)"
                    Write-Output "  • httpStatusCode   : $($errorJson.error.httpStatusCode)"
                    Write-Output "  • Timestamp        : $($errorJson.error.timeStamp)"
                   #Write-Output "  • RootActivityId   : $($errorJson.error.details[0].message)"
                }
            } catch {
                Write-Error "❌ [$operation] failed for: $ResourceID"
                Write-Error "  • Could not parse error message as JSON"
                Write-Error "  • Raw Message: $rawMessage"
            }
        }
    }
}
