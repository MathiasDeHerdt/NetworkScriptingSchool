﻿$ZoneFile = "1.168.192.in-addr.arpa.dns"

$IP = "192.168.1.2"
$MaskBits = 24 # This means subnet mask = 255.255.255.0
$Gateway = "192.168.1.1"
$Dns1 = "192.168.1.2"
$Dns2 = "192.168.1.3"
$IPType = "IPv4"

# Retrieve the network adapter that you want to configure
$adapter = Get-NetAdapter -Physical | Where-Object {$_.PhysicalMediaType -match "802.3" -and $_.Status -eq "up"}

# Remove any existing IP, gateway from our ipv4 adapter
If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
 $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
}

If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
 $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
}

 # Configure the IP address and default gateway
$adapter | New-NetIPAddress `
 -AddressFamily $IPType `
 -IPAddress $IP `
 -PrefixLength $MaskBits `
 -DefaultGateway $Gateway

# Configure the DNS client server IP addresses
$adapter | Set-DnsClientServerAddress -ServerAddresses ($Dns1, $Dns2)

Add-DnsServerPrimaryZone -NetworkId "192.168.1.0/24" -ReplicationScope Domain
Register-DnsClient