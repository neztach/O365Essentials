﻿function Get-O365MicrosoftSearch {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/configurations"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}