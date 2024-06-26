﻿function Set-O365PasswordReset {
    <#
    .SYNOPSIS
    Configures password reset settings for Office 365.

    .DESCRIPTION
    This function updates the settings for password reset policies in Office 365. It allows configuring various options such as authentication methods, notification settings, and security questions.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER EnablementType
    Specifies the type of enablement for the password reset policy.

    .PARAMETER NumberOfAuthenticationMethodsRequired
    Specifies the number of authentication methods required for password reset.

    .PARAMETER EmailOptionEnabled
    Indicates whether the email option is enabled for password reset.

    .PARAMETER MobilePhoneOptionEnabled
    Indicates whether the mobile phone option is enabled for password reset.

    .PARAMETER OfficePhoneOptionEnabled
    Indicates whether the office phone option is enabled for password reset.

    .PARAMETER SecurityQuestionsOptionEnabled
    Indicates whether the security questions option is enabled for password reset.

    .PARAMETER MobileAppNotificationEnabled
    Indicates whether the mobile app notification option is enabled for password reset.

    .PARAMETER MobileAppCodeEnabled
    Indicates whether the mobile app code option is enabled for password reset.

    .PARAMETER NumberOfQuestionsToRegister
    Specifies the number of security questions required to register for password reset.

    .PARAMETER NumberOfQuestionsToReset
    Specifies the number of security questions required to reset the password.

    .PARAMETER RegistrationRequiredOnSignIn
    Indicates whether registration is required on sign-in.

    .PARAMETER RegistrationReconfirmIntevalInDays
    Specifies the interval in days for reconfirming registration.

    .PARAMETER SkipRegistrationAllowed
    Indicates whether skipping registration is allowed.

    .PARAMETER SkipRegistrationMaxAllowedDays
    Specifies the maximum number of days allowed for skipping registration.

    .PARAMETER CustomizeHelpdeskLink
    Indicates whether the helpdesk link is customized.

    .PARAMETER CustomHelpdeskEmailOrUrl
    Specifies the custom helpdesk email or URL.

    .PARAMETER NotifyUsersOnPasswordReset
    Indicates whether users are notified on password reset.

    .PARAMETER NotifyOnAdminPasswordReset
    Indicates whether administrators are notified on password reset.

    .PARAMETER PasswordResetEnabledGroupIds
    Specifies the group IDs for which password reset is enabled.

    .PARAMETER PasswordResetEnabledGroupName
    Specifies the group name for which password reset is enabled.

    .PARAMETER EmailOptionAllowed
    Indicates whether the email option is allowed for password reset.

    .PARAMETER MobilePhoneOptionAllowed
    Indicates whether the mobile phone option is allowed for password reset.

    .PARAMETER OfficePhoneOptionAllowed
    Indicates whether the office phone option is allowed for password reset.

    .PARAMETER SecurityQuestionsOptionAllowed
    Indicates whether the security questions option is allowed for password reset.

    .PARAMETER MobileAppNotificationOptionAllowed
    Indicates whether the mobile app notification option is allowed for password reset.

    .PARAMETER MobileAppCodeOptionAllowed
    Indicates whether the mobile app code option is allowed for password reset.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365PasswordReset -Headers $headers -EnablementType 1 -NumberOfAuthenticationMethodsRequired 2 -EmailOptionEnabled $true
    
    This example configures the password reset policy with the specified settings.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[int]] $EnablementType                       , # = $CurrentSettings.enablementType #: 1
        [nullable[int]]$NumberOfAuthenticationMethodsRequired, # = $CurrentSettings.numberOfAuthenticationMethodsRequired #: 1
        [nullable[bool]] $EmailOptionEnabled                   , # = $CurrentSettings.emailOptionEnabled #: True
        [nullable[bool]] $MobilePhoneOptionEnabled             , # = $CurrentSettings.mobilePhoneOptionEnabled #: True
        [nullable[bool]] $OfficePhoneOptionEnabled             , # = $CurrentSettings.officePhoneOptionEnabled #: False
        [nullable[bool]] $SecurityQuestionsOptionEnabled       , # = $CurrentSettings.securityQuestionsOptionEnabled #: False
        [nullable[bool]] $MobileAppNotificationEnabled         , # = $CurrentSettings.mobileAppNotificationEnabled #: False
        [nullable[bool]] $MobileAppCodeEnabled                 , # = $CurrentSettings.mobileAppCodeEnabled #: True
        [nullable[int]]  $NumberOfQuestionsToRegister          , # = $CurrentSettings.numberOfQuestionsToRegister #: 5
        [nullable[int]] $NumberOfQuestionsToReset             , # = $CurrentSettings.numberOfQuestionsToReset #: 3
        [nullable[bool]] $RegistrationRequiredOnSignIn         , # = $CurrentSettings.registrationRequiredOnSignIn #: True
        [nullable[int]]$RegistrationReconfirmIntevalInDays   , # = $CurrentSettings.registrationReconfirmIntevalInDays #: 180
        [nullable[bool]] $SkipRegistrationAllowed              , # = $CurrentSettings.skipRegistrationAllowed #: True
        [nullable[int]] $SkipRegistrationMaxAllowedDays       , # = $CurrentSettings.skipRegistrationMaxAllowedDays #: 7
        [nullable[bool]] $CustomizeHelpdeskLink                , # = $CurrentSettings.customizeHelpdeskLink #: False
        [string] $CustomHelpdeskEmailOrUrl             , # = $CurrentSettings.customHelpdeskEmailOrUrl #:
        [nullable[bool]] $NotifyUsersOnPasswordReset           , # = $CurrentSettings.notifyUsersOnPasswordReset #: True
        [nullable[bool]] $NotifyOnAdminPasswordReset           , # = $CurrentSettings.notifyOnAdminPasswordReset #: True
        [string] $PasswordResetEnabledGroupIds         , # = $CurrentSettings.passwordResetEnabledGroupIds #: {b6cdb9c3-d660-4558-bcfd-82c14a986b56}
        [string] $PasswordResetEnabledGroupName        , # = $CurrentSettings.passwordResetEnabledGroupName #:
        # don't have details about those. needs investigations
        # $securityQuestions                    , # = $CurrentSettings.securityQuestions #: {}
        #$registrationConditionalAccessPolicies, # = $CurrentSettings.registrationConditionalAccessPolicies #: {}
        [nullable[bool]] $EmailOptionAllowed                   , # = $CurrentSettings.emailOptionAllowed #: True
        [nullable[bool]] $MobilePhoneOptionAllowed             , # = $CurrentSettings.mobilePhoneOptionAllowed #: True
        [nullable[bool]] $OfficePhoneOptionAllowed             , # = $CurrentSettings.officePhoneOptionAllowed #: True
        [nullable[bool]] $SecurityQuestionsOptionAllowed       , # = $CurrentSettings.securityQuestionsOptionAllowed #: True
        [nullable[bool]] $MobileAppNotificationOptionAllowed   , # = $CurrentSettings.mobileAppNotificationOptionAllowed #: True
        [nullable[bool]] $MobileAppCodeOptionAllowed            # = $CurrentSettings.mobileAppCodeOptionAllowed #: True
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/PasswordReset/PasswordResetPolicies"

    $CurrentSettings = Get-O365PasswordReset -Headers $Headers

    if ($CurrentSettings.objectId -ne 'default') {
        Write-Warning -Message "Set-O365PasswordReset - Getting current settings failed. Skipping changes."
        return
    }

    $Body = [ordered] @{
        objectId                              = $CurrentSettings.objectId #: default
        enablementType                        = $CurrentSettings.enablementType #: 1
        numberOfAuthenticationMethodsRequired = $CurrentSettings.numberOfAuthenticationMethodsRequired #: 1
        emailOptionEnabled                    = $CurrentSettings.emailOptionEnabled #: True
        mobilePhoneOptionEnabled              = $CurrentSettings.mobilePhoneOptionEnabled #: True
        officePhoneOptionEnabled              = $CurrentSettings.officePhoneOptionEnabled #: False
        securityQuestionsOptionEnabled        = $CurrentSettings.securityQuestionsOptionEnabled #: False
        mobileAppNotificationEnabled          = $CurrentSettings.mobileAppNotificationEnabled #: False
        mobileAppCodeEnabled                  = $CurrentSettings.mobileAppCodeEnabled #: True
        numberOfQuestionsToRegister           = $CurrentSettings.numberOfQuestionsToRegister #: 5
        numberOfQuestionsToReset              = $CurrentSettings.numberOfQuestionsToReset #: 3
        registrationRequiredOnSignIn          = $CurrentSettings.registrationRequiredOnSignIn #: True
        registrationReconfirmIntevalInDays    = $CurrentSettings.registrationReconfirmIntevalInDays #: 180
        skipRegistrationAllowed               = $CurrentSettings.skipRegistrationAllowed #: True
        skipRegistrationMaxAllowedDays        = $CurrentSettings.skipRegistrationMaxAllowedDays #: 7
        customizeHelpdeskLink                 = $CurrentSettings.customizeHelpdeskLink #: False
        customHelpdeskEmailOrUrl              = $CurrentSettings.customHelpdeskEmailOrUrl #:
        notifyUsersOnPasswordReset            = $CurrentSettings.notifyUsersOnPasswordReset #: True
        notifyOnAdminPasswordReset            = $CurrentSettings.notifyOnAdminPasswordReset #: True
        passwordResetEnabledGroupIds          = $CurrentSettings.passwordResetEnabledGroupIds #: {b6cdb9c3-d660-4558-bcfd-82c14a986b56}
        passwordResetEnabledGroupName         = $CurrentSettings.passwordResetEnabledGroupName #:
        securityQuestions                     = $CurrentSettings.securityQuestions #: {}
        registrationConditionalAccessPolicies = $CurrentSettings.registrationConditionalAccessPolicies #: {}
        emailOptionAllowed                    = $CurrentSettings.emailOptionAllowed #: True
        mobilePhoneOptionAllowed              = $CurrentSettings.mobilePhoneOptionAllowed #: True
        officePhoneOptionAllowed              = $CurrentSettings.officePhoneOptionAllowed #: True
        securityQuestionsOptionAllowed        = $CurrentSettings.securityQuestionsOptionAllowed #: True
        mobileAppNotificationOptionAllowed    = $CurrentSettings.mobileAppNotificationOptionAllowed #: True
        mobileAppCodeOptionAllowed            = $CurrentSettings.mobileAppCodeOptionAllowed #: True
    }

    if ($null -ne $EnablementType) {
        $Body.enablementType = $EnablementType
    }
    if ($null -ne $NumberOfAuthenticationMethodsRequired) {
        $Body.numberOfAuthenticationMethodsRequired = $NumberOfAuthenticationMethodsRequired
    }
    if ($null -ne $EmailOptionEnabled) {
        $Body.emailOptionEnabled = $EmailOptionEnabled
    }
    if ($null -ne $MobilePhoneOptionEnabled) {
        $Body.mobilePhoneOptionEnabled = $MobilePhoneOptionEnabled
    }
    if ($null -ne $OfficePhoneOptionEnabled) {
        $Body.officePhoneOptionEnabled = $OfficePhoneOptionEnabled
    }
    if ($null -ne $SecurityQuestionsOptionEnabled) {
        $Body.securityQuestionsOptionEnabled = $SecurityQuestionsOptionEnabled
    }
    if ($null -ne $MobileAppNotificationEnabled) {
        $Body.mobileAppNotificationEnabled = $MobileAppNotificationEnabled
    }
    if ($null -ne $MobileAppCodeEnabled) {
        $Body.mobileAppCodeEnabled = $MobileAppCodeEnabled
    }
    if ($null -ne $NumberOfQuestionsToRegister) {
        $Body.numberOfQuestionsToRegister = $NumberOfQuestionsToRegister
    }
    if ($null -ne $NumberOfQuestionsToReset) {
        $Body.numberOfQuestionsToReset = $NumberOfQuestionsToReset
    }
    if ($null -ne $RegistrationRequiredOnSignIn) {
        $Body.registrationRequiredOnSignIn = $RegistrationRequiredOnSignIn
    }
    if ($null -ne $RegistrationReconfirmIntevalInDays) {
        $Body.registrationReconfirmIntevalInDays = $RegistrationReconfirmIntevalInDays
    }
    if ($null -ne $SkipRegistrationAllowed) {
        $Body.skipRegistrationAllowed = $SkipRegistrationAllowed
    }
    if ($null -ne $SkipRegistrationMaxAllowedDays) {
        $Body.skipRegistrationMaxAllowedDays = $SkipRegistrationMaxAllowedDays
    }
    if ($CustomizeHelpdeskLink) {
        $Body.customizeHelpdeskLink = $CustomizeHelpdeskLink
    }
    if ($null -ne $CustomHelpdeskEmailOrUrl) {
        $Body.customHelpdeskEmailOrUrl = $CustomHelpdeskEmailOrUrl
    }
    if ($null -ne $NotifyUsersOnPasswordReset) {
        $Body.notifyUsersOnPasswordReset = $NotifyUsersOnPasswordReset
    }
    if ($null -ne $NotifyOnAdminPasswordReset) {
        $Body.notifyOnAdminPasswordReset = $NotifyOnAdminPasswordReset
    }
    if ($PasswordResetEnabledGroupName) {
        # We should find an easy way to find ID of a group and set it here
        $Group = Get-O365Group -DisplayName $PasswordResetEnabledGroupName
        if ($Group.id) {
            if ($Group -is [PSCustomObject]) {
                # Not implemented yet
                $Body.passwordResetEnabledGroupIds = @(
                    # Query for group id from group name $PasswordResetEnabledGroupName
                    $Group.id
                )
            } else {
                Write-Warning -Message "Set-O365PasswordReset - Group with name $PasswordResetEnabledGroupName not found or too many groups returned ($($Group.id -join ", "))"
                return
            }
        } else {
            Write-Warning -Message "Set-O365PasswordReset - Group with name $PasswordResetEnabledGroupName not found."
            return
        }
    } elseif ($PasswordResetEnabledGroupIds) {
        $Body.passwordResetEnabledGroupIds = @(
            $PasswordResetEnabledGroupIds
        )

        # This seems like an empty value - always
        $Body.passwordResetEnabledGroupName = ''
    }
    if ($null -ne $SecurityQuestions) {
        $Body.securityQuestions = $SecurityQuestions
    }
    if ($null -ne $RegistrationConditionalAccessPolicies) {
        $Body.registrationConditionalAccessPolicies = $RegistrationConditionalAccessPolicies
    }
    if ($null -ne $EmailOptionAllowed) {
        $Body.emailOptionAllowed = $EmailOptionAllowed
    }
    if ($null -ne $MobilePhoneOptionAllowed) {
        $Body.mobilePhoneOptionAllowed = $MobilePhoneOptionAllowed
    }
    if ($null -ne $OfficePhoneOptionAllowed) {
        $Body.officePhoneOptionAllowed = $OfficePhoneOptionAllowed
    }
    if ($null -ne $SecurityQuestionsOptionAllowed) {
        $Body.securityQuestionsOptionAllowed = $SecurityQuestionsOptionAllowed
    }
    if ($null -ne $mobileAppNotificationOptionAllowed) {
        $Body.mobileAppNotificationOptionAllowed = $mobileAppNotificationOptionAllowed
    }
    if ($null -ne $mobileAppCodeOptionAllowed) {
        $Body.mobileAppCodeOptionAllowed = $mobileAppCodeOptionAllowed
    }

    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
}
