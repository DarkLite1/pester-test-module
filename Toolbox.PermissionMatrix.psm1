Function Get-AdUserPrincipalNameHC {
    Param(
        [Parameter(Mandatory)]
        [String[]]$Name
    )

    $notFound = @()

    $result = foreach ($N in  ($Name | Sort-Object -Unique)) {
        $adObject = Get-ADObject -Filter "ProxyAddresses -eq 'smtp:$N' -or SAMAccountName -eq '$N'" -Property 'mail'

        if ($adObject.Count -ge 2) {
            throw "Multiple results found for name '$N': $($adObject.Name)"
        }
    
        if (-not $adObject) {
            $notFound += $N
            Continue
        }
    
        $adUsers = if ($adObject.ObjectClass -eq 'group') {
            Get-ADGroupMember $adObject -Recursive
        }
        elseif ($adObject.ObjectClass -eq 'user') {
            $adObject
        }
    
        $adUsers | Get-ADUser | Where-Object { $_.Enabled } |
        Select-Object -ExpandProperty 'UserPrincipalName'
    }
    
    @{
        notFound          = $notFound
        userPrincipalName = $result | Sort-Object -Unique
    }    
}

Export-ModuleMember -Function * -Alias *