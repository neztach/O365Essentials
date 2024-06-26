﻿function Invoke-O365Admin {
    <#
    .SYNOPSIS
    This function is used to make administrative calls to the Office 365 API.

    .DESCRIPTION
    This function is responsible for sending requests to the Office 365 API for administrative tasks.

    .PARAMETER Uri
    The URI endpoint for the API request.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER Method
    The HTTP method to be used for the request (GET, DELETE, POST, PATCH, PUT).

    .PARAMETER ContentType
    The content type of the request body.

    .PARAMETER Body
    The body of the request, if applicable.

    .PARAMETER QueryParameter
    The query parameters for the request.
    #>
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [uri] $Uri,
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [validateset('GET', 'DELETE', 'POST', 'PATCH', 'PUT')][string] $Method = 'GET',
        [string] $ContentType = "application/json; charset=UTF-8",
        [System.Collections.IDictionary] $Body,
        [System.Collections.IDictionary] $QueryParameter
    )
    if (-not $Headers -and $Script:AuthorizationO365Cache) {
        # This forces a reconnect of session in case it's about to time out. If it's not timeouting a cache value is used
        $Headers = Connect-O365Admin -Headers $Headers
    } elseif ($Headers) {
        $Headers = Connect-O365Admin -Headers $Headers
    } else {
        Write-Warning "Invoke-O365Admin - Not connected. Please connect using Connect-O365Admin."
        return
    }
    if (-not $Headers) {
        Write-Warning "Invoke-O365Admin - Authorization error. Skipping."
        return
    }
    $RestSplat = @{
        Method      = $Method
        ContentType = $ContentType
    }
    if ($Uri -like '*admin.microsoft.com*') {
        $RestSplat['Headers'] = $Headers.HeadersO365
    } elseif ($Uri -like '*graph.microsoft.com*') {
        $RestSplat['Headers'] = $Headers.HeadersGraph
    } else {
        $RestSplat['Headers'] = $Headers.HeadersAzure
    }

    if ($PSVersionTable.PSVersion.Major -eq 5) {
        $CookieContainer = [System.Net.CookieContainer]::new()
        $CookieContainer.MaxCookieSize = 1048576

        $Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        $Session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36 Edg/93.0.961.38"
        $Session.Cookies = $CookieContainer
        $RestSplat['WebSession'] = $Session
    }

    #$RestSplat.Headers."x-ms-mac-hosting-app" = 'M365AdminPortal'
    #$RestSplat.Headers."x-ms-mac-version" = 'host-mac_2021.8.16.1'
    #$RestSplat.Headers."sec-ch-ua" = '"Chromium";v="92", " Not A;Brand";v="99", "Microsoft Edge";v="92"'
    #$RestSplat.Headers."x-portal-routekey" = 'weu'
    #$RestSplat.Headers."x-ms-mac-appid" = 'feda2aab-4737-4646-a86c-98a7742c70e6'
    #$RestSplat.Headers."x-adminapp-request" = '/Settings/Services/:/Settings/L1/Whiteboard'
    #$RestSplat.Headers."x-ms-mac-target-app" = 'MAC'
    #$RestSplat.UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36 Edg/92.0.902.73'
    #$RestSplat.Headers.Cookie = 'MC1=GUID=480c128a5ba04faea7df151a53bdfa9a&HASH=480c&LV=202107&V=4&LU=1627670649689'

    #$RestSplat.Headers."x-ms-mac-hosting-app" = 'M365AdminPortal'
    #$RestSplat.Headers."x-adminapp-request" = '/Settings/Services/:/Settings/L1/EndUserCommunications'
    #$RestSplat.Headers."Referer" = 'https://admin.microsoft.com/'
    #$RestSplat.Headers."AjaxSessionKey" = 'x5eAwqzbVehBOP7QHfrjpwr9eYtLiHJt7TZFj0uhUMUPQ2T7yNdA7rEgOulejHDHYM1ZyCT0pgXo96EwrfVpMA=='
    #$RestSplat.Headers."etag" = '1629993527.826253_3ce8143d'

    if ($Body) {
        $RestSplat['Body'] = $Body | ConvertTo-Json -Depth 5
    }
    $RestSplat.Uri = Join-UriQuery -BaseUri $Uri -QueryParameter $QueryParameter
    if ($RestSplat['Body']) {
        $WhatIfInformation = "Invoking [$Method] " + [System.Environment]::NewLine + $RestSplat['Body'] + [System.Environment]::NewLine
    } else {
        $WhatIfInformation = "Invoking [$Method] "
    }
    try {
        Write-Verbose "Invoke-O365Admin - $($WhatIfInformation)over URI $($RestSplat.Uri)"
        if ($Method -eq 'GET') {
            # We use separate check because WHATIF would sometimes trigger when GET was used inside a SET
            $OutputQuery = Invoke-RestMethod @RestSplat -Verbose:$false
            if ($null -ne $OutputQuery) {
                if ($OutputQuery -is [bool]) {
                    $OutputQuery
                } elseif ($OutputQuery -is [array]) {
                    $Properties = $OutputQuery | Select-Properties -ExcludeProperty '@odata.context', '@odata.id', '@odata.type', 'Length' -WarningAction SilentlyContinue -WarningVariable varWarning
                    if (-not $varWarning) {
                        $OutputQuery | Select-Object -Property $Properties
                    }
                } elseif ($OutputQuery -is [string]) {
                    if ($OutputQuery) {
                        $Properties = $OutputQuery | Select-Properties -ExcludeProperty '@odata.context', '@odata.id', '@odata.type', 'Length' -WarningAction SilentlyContinue -WarningVariable varWarning
                        if (-not $varWarning) {
                            $OutputQuery | Select-Object -Property $Properties
                        }
                    }
                } elseif ($OutputQuery -is [PSCustomObject]) {
                    if ($OutputQuery.PSObject.Properties.Name -contains 'value') {
                        $Properties = $OutputQuery.value | Select-Properties -ExcludeProperty '@odata.context', '@odata.id', '@odata.type', 'Length' -WarningAction SilentlyContinue -WarningVariable varWarning
                        if (-not $varWarning) {
                            $OutputQuery.value | Select-Object -Property $Properties
                        }
                    } else {
                        $Properties = $OutputQuery | Select-Properties -ExcludeProperty '@odata.context', '@odata.id', '@odata.type', 'Length' -WarningAction SilentlyContinue -WarningVariable varWarning
                        if (-not $varWarning) {
                            $OutputQuery | Select-Object -Property $Properties
                        }
                    }
                } else {
                    Write-Warning -Message "Invoke-O365Admin - Type $($OutputQuery.GetType().Name) potentially unsupported."
                    $OutputQuery
                }
            }
            if ($OutputQuery -isnot [array]) {
                if ($OutputQuery.'@odata.nextLink') {
                    $RestSplat.Uri = $OutputQuery.'@odata.nextLink'
                    if ($RestSplat.Uri) {
                        # We must remove websession parameter because Invoke-o365admin doesn't have it and i don't want to add it to the code
                        # it will set it self anyways
                        $RestSplat.Remove('WebSession')
                        # We need to reset the headers to full header, rather than the one that was used to invoke the previous call
                        $RestSplat.Headers = $Headers
                        # Not sure if this is best/fastest way to do it, but it works
                        # It's a bit better than saving it to variable and releasing everything later on as it can be used in pipeline
                        Invoke-O365Admin @RestSplat | ForEach-Object { if ($null -ne $_) { $_ } }
                        #if ($null -ne $MoreData) {
                        #    $MoreData
                        #}
                    }
                }
            }
        } else {
            if ($PSCmdlet.ShouldProcess($($RestSplat.Uri), $WhatIfInformation)) {
                #$CookieContainer = [System.Net.CookieContainer]::new()
                #$CookieContainer.MaxCookieSize = 8096
                $OutputQuery = Invoke-RestMethod @RestSplat -Verbose:$false
                if ($Method -in 'POST', 'PUT') {
                    if ($null -ne $OutputQuery) {
                        $OutputQuery
                    }
                } else {
                    return $true
                }
            }
        }
    } catch {
        if ($PSBoundParameters.ErrorAction -eq 'Stop') {
            Write-Error $_
            return
        }
        $RestError = $_.ErrorDetails.Message
        $RestMessage = $_.Exception.Message
        if ($RestError) {
            try {
                $ErrorMessage = ConvertFrom-Json -InputObject $RestError -ErrorAction Stop
                $ErrorText = $ErrorMessage.error.message
                # Write-Warning -Message "Invoke-O365Admin - [$($ErrorMessage.error.code)] $($ErrorMessage.error.message), exception: $($_.Exception.Message)"
                Write-Warning -Message "Invoke-O365Admin - Error: $($RestMessage) $($ErrorText)"
            } catch {
                $ErrorText = ''
                Write-Warning -Message "Invoke-O365Admin - Error: $($RestMessage)"
            }
        } else {
            Write-Warning -Message "Invoke-O365Admin - Error: $($_.Exception.Message)"
        }
        if ($_.ErrorDetails.RecommendedAction) {
            Write-Warning -Message "Invoke-O365Admin - Recommended action: $RecommendedAction"
        }
        if ($Method -notin 'GET', 'POST') {
            return $false
        }
    }
}
