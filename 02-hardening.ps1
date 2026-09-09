Set-ADDomain -Identity "DC=ccdz,DC=lan" -Replace @{"ms-DS-MachineAccountQuota"="0"}
Enable-ADOptionalFeature -Identity 'CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=ccdz,DC=lan' -Scope ForestOrConfigurationSet -Target 'ccdz.lan'

# Show OU can accidentally delete
Get-ADOrganizationalUnit -filter {name -like "*"} -Properties ProtectedFromAccidentalDeletion | format-table Name,ProtectedFromAccidentalDeletion

# Set OU to be protected from accidental deletion
Get-ADOrganizationalUnit -filter {name -like "*"} -Properties ProtectedFromAccidentalDeletion | where {$_.ProtectedFromAccidentalDeletion -eq $false} | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $true


# Disable rootDse Anonymous Binding
$configDN = (Get-ADRootDSE).configurationNamingContext
$obj = Get-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,$configDN" -Properties msDS-Other-Settings
Set-ADObject -Identity $obj -Add @{'msDS-Other-Settings'='DenyUnauthenticatedBind=1'}

# Verify that the setting has been applied
Get-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,$((Get-ADRootDSE).configurationNamingContext)" -Properties msDS-Other-Settings | Select-Object -ExpandProperty msDS-Other-Settings

# Enable AES encryption for Kerberos
Get-ADObject -LDAPFilter "(&(!(msDS-SupportedEncryptionTypes=*))(|(objectClass=user)(objectClass=computer)(objectClass=msDS-GroupManagedServiceAccount)))" | Set-ADObject -Replace @{"msDS-SupportedEncryptionTypes" = 24}