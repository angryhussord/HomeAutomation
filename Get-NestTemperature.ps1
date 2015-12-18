function Get-NestThermostatTemperature{

[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]

param
(

    [parameter(
        ParameterSetName="url",
        ValueFromPipeline=$true,
        Mandatory=$true)]
        [string]
        $AccessTokenUrl,

    [parameter(
        ParameterSetName="codewithid",
        ValueFromPipeline=$true,
        Mandatory=$true)]
        [string]
        $AuthorizationCode,


    [parameter(
        ParameterSetName="codewithid",
        ValueFromPipeline=$true,
        Mandatory=$true)]
        [string]
        $ClientId,

    [parameter(
        ParameterSetName="codewithid",
        ValueFromPipeline=$true,
        Mandatory=$true)]
        [string]
        $ClientSecret

)#end param

BEGIN 
{ 

    if ($PSCmdlet.ParameterSetName -eq "codewithid")
    {
    $reqAccessTokenUrl = "https://api.home.nest.com/oauth2/access_token?client_id=$($ClientId)&code=$($AuthorizationCode)&client_secret=$($ClientSecret)&grant_type=authorization_code"
    }
    else{
        $reqAccessTokenUrl = $AccessTokenUrl
    }


} #End BEGIN

PROCESS
{}#end PROCESS

END
{
    $accessToken = Invoke-RestMethod -Uri $reqAccessTokenUrl
    $thermostatDevices = Invoke-RestMethod "https://developer-api.nest.com/devices?auth=$($accessToken.access_token)"
}#end END

}