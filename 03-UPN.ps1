# This script adds UPN suffixes in Active Directory.
Get-ADForest | Set-ADForest -UPNSuffixes @{add="domain.tld","domain2.tld"}

# This script removes UPN suffixes in Active Directory.
Get-ADForest | Set-ADForest -UPNSuffixes @{remove="domain.tld","domain2.tld"}