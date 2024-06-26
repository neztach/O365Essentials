﻿function Get-O365OrgOfficeProductivity {
    <#
    .SYNOPSIS
    Retrieves productivity score information for the organization.

    .DESCRIPTION
    This function retrieves productivity score information for the organization from the specified URIs.

    .PARAMETER Headers
    Authentication token and additional information created with Connect-O365Admin.

    .EXAMPLE
    Get-O365OrgOfficeProductivity -Headers $headers

    .NOTES
    This function retrieves productivity score information from the specified URIs.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/reports/productivityScoreCustomerOption"
    $Output1 = Invoke-O365Admin -Uri $Uri -Headers $Headers

    #$Uri = "https://admin.microsoft.com/admin/api/reports/productivityScoreConfig/GetProductivityScoreConfig"
    #$Output2 = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output1) {
        #$Output2Json = $Output2.Output | ConvertFrom-Json
        $Output1Json = $Output1.Output | ConvertFrom-Json
        $Output = [PSCustomObject] @{
            #TenantId                  = $Output2Json.TenantId
            #ProductivityScoreSignedup = $Output2Json.ProductivityScoreSignedup
            #SignupUserPuid            = $Output2Json.SignupUserPuid
            #SignupTime                = $Output2Json.SignupTime
            #ReadyTime                 = $Output2Json.ReadyTime
            ProductivityScoreOptedIn = $Output1Json.ProductivityScoreOptedIn
            OperationUserPuid        = $Output1Json.OperationUserPuid
            OperationTime            = $Output1Json.OperationTime
        }
        $Output
    }
}
