param (
	[string]$mac
)
#$mac = "C8-60-00-BD-48-CA";
$MacByteArray = $mac -split "[:-]" | ForEach-Object { [Byte] "0x$_"};
[Byte[]] $MagicPacket = (,0xFF * 6) + ($MacByteArray  * 16);
$UdpClient = New-Object System.Net.Sockets.UdpClient;
$UdpClient.Connect(([System.Net.IPAddress]::Broadcast),7);
$UdpClient.Send($MagicPacket,$MagicPacket.Length) | Out-Null;
$UdpClient.Close();