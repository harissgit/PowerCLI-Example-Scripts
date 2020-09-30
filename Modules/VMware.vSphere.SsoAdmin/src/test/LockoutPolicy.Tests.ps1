#**************************************************************************
# Copyright (c) VMware, Inc. All rights reserved.
#**************************************************************************

param(
    [Parameter(Mandatory = $true)]
    [string]
    $VcAddress,

    [Parameter(Mandatory = $true)]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [string]
    $Password
)

# Import Vmware.vSphere.SsoAdmin Module
$modulePath = Join-Path (Split-Path $PSScriptRoot | Split-Path) "VMware.vSphere.SsoAdmin.psd1"
Import-Module $modulePath

Describe "LockoutPolicy Tests" {
   BeforeEach {
      Connect-SsoAdminServer `
         -Server $VcAddress `
         -User $User `
         -Password $Password `
         -SkipCertificateCheck
   }

   AfterEach {
      $connectionsToCleanup = $global:DefaultSsoAdminServers.ToArray()
      foreach ($connection in $connectionsToCleanup) {
         Disconnect-SsoAdminServer -Server $connection
      }
   }

   Context "Get-LockoutPolicy" {
      It 'Gets lockout policy' {
         # Act
         $actual = Get-LockoutPolicy

         # Assert
         $actual | Should Not Be $null
      }
   }

   Context "Set-LockoutPolicy" {
      It 'Updates lockout policy AutoUnlockIntervalSec and MaxFailedAttempts' {
         # Arrange
         $lockoutPolicyToUpdate = Get-LockoutPolicy
         $expectedAutoUnlockIntervalSec = 33
         $expectedMaxFailedAttempts = 7

         # Act
         $actual = Set-LockoutPolicy `
            -LockoutPolicy $lockoutPolicyToUpdate `
            -AutoUnlockIntervalSec $expectedAutoUnlockIntervalSec `
            -MaxFailedAttempts $expectedMaxFailedAttempts

         # Assert
         $actual | Should Not Be $null
         $actual.AutoUnlockIntervalSec | Should Be $expectedAutoUnlockIntervalSec
         $actual.MaxFailedAttempts | Should Be $expectedMaxFailedAttempts
         $actual.FailedAttemptIntervalSec | Should Be $lockoutPolicyToUpdate.FailedAttemptIntervalSec
         $actual.Description | Should Be $lockoutPolicyToUpdate.Description

         # Cleanup
         $lockoutPolicyToUpdate | Set-LockoutPolicy
      }
   }
}