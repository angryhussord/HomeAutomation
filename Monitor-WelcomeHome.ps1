#Pat's Samsung Galaxy S6 = 192.168.1.201
#Steph's Samsung Galaxy S6 = 192.168.1.202
param (
    $password,
    $username,
    $ip='192.168.1.201'
)

Set-Variable DisconnectTimeout -option Constant -value 2;
Set-Variable ConnectionLog -option Constant -value "c:\HomeAutomation\Logs\Phone\Patrick-GS6.log";

function Write-ConnectionLog () {
    param(
        [string]$State,
        [datetime]$Timestamp,
        [string]$Filename
        )

    if (! (Test-Path -Path $ConnectionLog) ) {
        md "c:\HomeAutomation\Logs\Phone\" | Out-Null;
        Set-Content $ConnectionLog "[$Timestamp] Device status changed to $State.";
    } else {
        if ($State -eq "Sleep") {
            Add-Content $ConnectionLog "[$Timestamp] Workstation was just put to $State due to 30 minutes of device disconnection.";    
        }
        Add-Content $ConnectionLog "[$Timestamp] Device status changed to $State.";
    }
}

$PWord = ConvertTo-SecureString –String $password –AsPlainText -Force;
$Credential = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $username, $PWord;

$last_state = $false;
$last_seen = Get-Date;
$curr_state = $false;
$curr_time = Get-Date;

while ($true) {
	#Check to see if it's online
    $curr_state = (ping $ip -n 1)[5] -match "Received = 1";
    $curr_time = Get-Date;
	if ($curr_state) {
        #Currently Online
        if ($last_state) {
            #Continued to stay Online
            #Update the time it was last seen online
            $last_seen = Get-Date;
        } else {
            #Newly Connected
            #Send text message welcome
            Send-MailMessage -To 4252933450@vtext.com -From "hufford@gmail.com" -Body "Welcome Home Patrick! You reconnected at $(Get-Date). Enjoy your stay." -SmtpServer "smtp.gmail.com" -Subject "Welcome Home!" -Credential $Credential -Port 587 -UseSsl;
            #Wake up workstation
            .\Send-MagicPacket.ps1 -mac "C8-60-00-BD-48-CA";
            #Update state variables
            $last_seen = Get-Date;
            $last_state = $true;
            #Write the change to the log
            Write-ConnectionLog -State "Connected" -Timestamp $curr_time -Filename $ConnectionLog;
        }
    } else {
        #Not Online
        if ($last_state) {
            #Disconnected recently
            #At the state change, we don't do anything but log it, minor interruptions in connectivity are normal, only take action after extended periods of being disconnected
            #Write the change to the log
            Write-ConnectionLog -State "Disconnected" -Timestamp $curr_time -Filename $ConnectionLog;
        } else {
            #Continue to be offline
            #Only change state to false if it's been a few minutes since the last time we were online
            $timespan = $curr_time - $last_seen;
            if ($timespan.Minutes -gt $DisconnectTimeout) {
                $last_state = $false;
            }
            #If it's been 30 minutes that we've been continuously offline, send a Sleep command to the workstation
            if ($timespan.Minutes -gt ($DisconnectTimeout * 10)) {
                #Send a sleep command to dagathon.hufford.org
                $session = New-PSSession -ComputerName dagathon.hufford.org -Credential $Credential;
                [ScriptBlock]$Block = {
                    # Define the power state you wish to set
                    $PowerState = [System.Windows.Forms.PowerState]::Suspend;
                    # Choose whether or not to force the power state
                    $Force = $false;
                    # Choose whether or not to disable wake capabilities
                    $DisableWake = $false;
                    # Set the power state
                    [System.Windows.Forms.Application]::SetSuspendState($PowerState, $Force, $DisableWake);
                }
                $result = Invoke-Command -Session $session -ScriptBlock $Block -AsJob
                Write-ConnectionLog -State "Sleep" -Timestamp $curr_time -Filename $ConnectionLog;
            }
        }
    }
}