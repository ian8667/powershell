#* FileName: nic_address.ps1
#* Source: http://www.powershellpro.com/organizing-powershell-script-code-is-a-snap-in/102/
#*=============================================
#* Script Name: address_details.ps1
#* Created: 2011-12-24
#* Author: Ian Molloy
#* Reqrmnts: PowerShell
#* Keywords: ip address gateway
#*
#* The web site at
#* http://www.powershellpro.com/powershell-tutorial-introduction/powershell-wmi-methods/
#* contains an article on configuring NIC's via a script.
#* I've yet to try it though.
#*
#* Note1: for details of parameters and the syntax used
#* in this example, see 'about_Functions_Advanced_Parameters'
#* at http://technet.microsoft.com/en-us/library/dd347600.aspx
#*
#* Note2: Parameter Validation Attributes.
#* Parameter validation attributes are used to test the
#* parameter values that users submit when they call the
#* advanced function. If the parameter values fail the test,
#* an error is generated and the function is not called.
#*=============================================
#* Purpose:
#* This script can be used after changing the 'Local Area
#* Connection' network interface card (NIC) addresses details
#* to check that the addresses seem OK and we have network
#* connectivity as expected. This script assumes the network
#* card addresses have already been correctly changed.
#*=============================================
#* An alternative way of pinging a machine.
#*
#* If (Test-Connection -ComputerName $computer -Count 1 -TimeToLive 4 -Quiet) {
#*   Write-Host "Computer online";
#* }
#* Else {
#*   Write-Warning "Computer $computer is offline";
#* }
#*
#* or
#*
#* function Ping ([String] $strComputer)
#* {
#*   $timeout=120;
#*   trap { continue; }
#*  
#*   $ping = New-Object System.Net.NetworkInformation.Ping 
#*   $reply = New-Object System.Net.NetworkInformation.PingReply
#*
#*   $reply = $ping.Send($strComputer, $timeout);
#*   if( $reply.Status -eq "Success"  ) 
#*   {
#*      return $true;
#*   }
#*   return $false;
#* 
#* }
#*
#*=============================================

#region ********** Function pingAddress **********
#* Function: pingAddress
#* Created: 2011-12-22
#* Author: Ian Molloy
#*
#* Arguments:
#* $ipaddress - the IP address to ping.
#* $msg - message to print alongside the IP address.
#*
#* Ping Class
#* Allows an application to determine whether a remote computer
#* is accessible over the network.
#* See http://msdn.microsoft.com/en-us/library/a63bsyf0.aspx
#*
#* Note:
#* For a list of colors that can be used with the 'ForegroundColor'
#* and 'BackgroundColor' parameters, see
#* http://technet.microsoft.com/en-us/library/dd347596.aspx
#* or
#* http://technet.microsoft.com/en-us/library/ee177031.aspx
#*
#* See also:
#* System.Net.NetworkInformation.PingReply
#* http://msdn.microsoft.com/en-us/library/system.net.networkinformation.pingreply.aspx
#*=============================================
#* Purpose:
#* Pings the IP address supplied
#*=============================================
function pingAddress {
[cmdletbinding()]
Param (
    [parameter(Mandatory=$true,
               HelpMessage="IP address to ping")]
    [ValidateNotNullOrEmpty()]
    [String]$ipaddress,

    [parameter(Mandatory=$true,
               HelpMessage="Message to print with the address")]
    [ValidateNotNullOrEmpty()]
    [String]$msg
) #end param

  #Write-Host "Pinging an address of $ipaddress"
  $pping = New-Object System.Net.NetworkInformation.Ping;
  $rslt = $pping.Send($ipaddress);
  if ($rslt.Status.ToString() -eq "Success")
  {
       Write-Host "ping worked with $msg $ipaddress" -ForegroundColor Green;
       $global:pingOk++;
  }
  else
  {
       Write-Host "ping failed with $ipaddress" -ForegroundColor Red -BackgroundColor Yellow;
       $global:pingFail++;
  }
  Write-Host "";

}
#endregion ***** End of function pingAddress *****

#----------------------------------------------------------

#region ***** Function getAddress *****
#* Function: getAddress
#* Created: 2011-12-22
#* Author: Ian Molloy
#*
#* Arguments:
#* None used.
#*
#* NOTE:
#* The 'Win32_NetworkAdapterConfiguration' WMI class
#* represents the attributes and behaviors of a network
#* adapter. See the following web site for details.
#* http://msdn.microsoft.com/en-us/library/windows/desktop/aa394217(v=vs.85).aspx
#*=============================================
#* Purpose:
#* Obtains the computer name and the following
#* machine related IP addresses:
#*    o Machines IP Address
#*    o Subnet mask
#*    o Default gateway
#*=============================================
function getAddress {
[CmdletBinding()]
Param() #end param

  $filter = "DHCPEnabled = 'True'";
  $namespace = "root\CimV2";
  #$strComputer = Get-Content env:COMPUTERNAME;
  $Computer = [System.Net.Dns]::GetHostName();
  $colItems = Get-WMiObject `
                  -Class Win32_NetworkAdapterConfiguration `
                  -Namespace $namespace `
                  -ComputerName $Computer `
                  -Filter $filter |
              Where-Object {$_.IPAddress -ne $null};

  Write-Host "Network address details for computer $Computer";
  Write-Host "";

  ForEach ($item in $colItems)
  {

     Write-Host ("Computer Name is :  {0}" -f $Computer);
     Write-Host ("IP Address       :  {0}" -f $item.IpAddress);
     Write-Host ("Subnet mask      :  {0}" -f $item.IPSubnet);
     Write-Host ("Default gateway  :  {0}" -f $item.DefaultIPGateway);
     Write-Host ("Adapter name     :  {0}" -f $item.Description);
     Write-Host "";

     # Ping the machine IP address.
     $ipaddress=$item.IpAddress[0];
     pingAddress $ipaddress "my own IP address";

     # Ping the default gateway address.
     $gateway = $item.DefaultIPGateway[0];
     pingAddress $gateway "my gateway address";

  }

}
#endregion ***** End of function getAddress *****

#----------------------------------------------------------

#region ***** script body *****
##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

[Int32]$global:pingOk=0;
[Int32]$global:pingFail=0;

Write-Host "";
Get-Date -format U;
$user = [System.Environment]::UserName;
Write-Host "You're currently logged in as user $user";

# Get the addresses for the machine.
getAddress;

# See if this outside world address pings.
pingAddress "8.8.8.8" "an outside world address";

# See if this outside world address pings.
pingAddress "194.168.4.100" "an outside world address";

Write-Host ("Ping results, {0} addresses succeeded, {1} failed" `
             -f "$pingOk", "$pingFail");

$dd = Get-Date -Format "dddd, dd MMMM yyyy"
Write-Host "Current date/time: $dd";

#*=============================================
#* END OF SCRIPT: nic_address.ps1
#*=============================================
#endregion ********** End of script body **********
