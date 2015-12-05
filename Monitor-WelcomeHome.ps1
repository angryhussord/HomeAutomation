#Pat's Samsung Galaxy S6 = 192.168.1.201
#Steph's Samsung Galaxy S6 = 192.168.1.202
param (
    $password,
    $username,
    $ip='192.168.1.201'
)

$online = $false;
$welcome_sent = $false;
while ($true) {
	$attempt_ping = (ping $ip -n 1)[5] -match "Received = 1";
	if ($attempt_ping) {
		if (! $welcome_sent) {
			$online = $true;
			$PWord = ConvertTo-SecureString –String $password –AsPlainText -Force;
			$Credential = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $username, $PWord;
			Send-MailMessage -To 4252933450@vtext.com -From "hufford@gmail.com" -Body "Welcome Home Patrick! You reconnected at $(Get-Date). Enjoy your stay." -SmtpServer "smtp.gmail.com" -Subject "Welcome Home!" -Credential $Credential -Port 587 -UseSsl;
            Wake-RemoteComputer.ps1 -mac "C8-60-00-BD-48-CA";
			$welcome_sent = $true;
		}
	} else {
		#user is offline, reset and continue the loop
		$online = $false;
		$welcome_sent = $false;
	}	
	#use this to throttle how often we check for the phone being online
	Sleep -Seconds 30;
}