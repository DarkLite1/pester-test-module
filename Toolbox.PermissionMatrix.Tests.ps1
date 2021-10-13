BeforeDiscovery {
    $moduleName = 'Toolbox.PermissionMatrix'

    $testScript = $PSCommandPath.Replace('.Tests.ps1', '.psm1')

    Remove-Module $moduleName -Force -Verbose:$false -EA Ignore
    Import-Module $testScript -Force -Verbose:$false
}
Describe 'Get-AdUserPrincipalNameHC' {
    Context 'a user e-mail address is' {
        It 'converted to the userPrincipalName for an enabled account' {
            Mock Get-ADObject {
                New-Object Microsoft.ActiveDirectory.Management.ADObject Identity -Property @{
                    mail        = 'bob@mail.com'
                    ObjectClass = 'user'
                }                
            } -ModuleName $moduleName
            Mock Get-ADUser {
                New-Object Microsoft.ActiveDirectory.Management.ADUser Identity -Property @{
                    Enabled           = $true
                    UserPrincipalName = 'bob@contoso.com'
                }
            } -ModuleName $moduleName

            $actual = Get-AdUserPrincipalNameHC -Name 'bob@mail.com'

            $actual.userPrincipalName | Should -Be 'bob@contoso.com'
            $actual.notFound | Should -BeNullOrEmpty
        }
    }
} 