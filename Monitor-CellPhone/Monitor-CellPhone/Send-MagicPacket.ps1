param (
	[string]$mac
)

#Originally written by Kris Powell
#Source: http://www.adminarsenal.com/admin-arsenal-blog/powershell-sending-a-wake-on-lan-wol-magic-packet

#Split on either the : or - separator in the MAC address and convert to a byte array
$MacByteArray = $mac -split "[:-]" | ForEach-Object { [Byte] "0x$_"};

#Build the packet, 6 bytes of 0xFF followed by 16 copies of the MAC address
[Byte[]] $MagicPacket = (,0xFF * 6) + ($MacByteArray * 16);

#Create a new UDPClient
$UdpClient = New-Object System.Net.Sockets.UdpClient;

#Broadcast the packet on the network
$UdpClient.Connect(([System.Net.IPAddress]::Broadcast),7);
$UdpClient.Send($MagicPacket,$MagicPacket.Length) | Out-Null;

#Close the UDPClient
$UdpClient.Close();