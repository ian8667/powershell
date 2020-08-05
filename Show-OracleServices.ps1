<#
.SYNOPSIS

Shows Oracle related MS Windows services

.DESCRIPTION

Lists the Oracle related Microsoft Windows services (if any).
A warning message is printed if no services are found.

It's assumed the computer name supplied as a parameter is
running the Microsoft Windows Operating System.

.PARAMETER ComputerName

The name of the computer that you wish to list the Oracle services
A warning message is generated if the computer is not online.

This is a mandatory parameter.

.EXAMPLE

./Show-OracleServices.ps1 hqpdopusdb1

A positional parameter has been supplied so information for this
computer will be listed.

.EXAMPLE

./Show-OracleServices.ps1 -ComputerName localhost

Using a named parameter to supply the computer name for which
information will be listed.

.EXAMPLE

./Show-OracleServices.ps1

As no parameters have been supplied, you will be prompted for
the computer name. As above, inforamtion will then be listed
for the computer concerned.

.INPUTS

None. No .NET Framework types of objects are used as input.

.OUTPUTS

None. No .NET Framework types of objects are output from this script.

.NOTES

Computer name is synonymous with server name.

Additional information about the function or script.
Additional Notes, eg:

File Name    : Show-OracleServices.ps1
Author       : Ian Molloy
Last updated : 2020-08-05T11:12:36

For information regarding this subject (comment-based help),
execute the command:
PS> Get-Help about_comment_based_help

.LINK

about_Comment_Based_Help
http://technet.microsoft.com/en-us/library/dd819489.aspx

WTFM: Writing the Fabulous Manual
http://technet.microsoft.com/en-us/magazine/ff458353.aspx

about_Functions_Advanced_Parameters
http://technet.microsoft.com/en-us/library/hh847743.aspx

Cmdlet Parameter Sets
http://msdn.microsoft.com/en-us/library/windows/desktop/dd878348(v=vs.85).aspx
#>

[cmdletbinding()]
Param (
    [parameter(Mandatory=$true,
               HelpMessage="Enter the computer name to look at",
               Position=0)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ComputerName
) #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function ping *****
#*=============================================
#* Function: Ping
#* Created: 2013-05-25
#* Author: Ian Molloy
#* Arguments: ComputerName - the computer to check
#*=============================================
#* Purpose:
#* Determines whether the computer is online or not.
#* Returns:
#* true if and only if the computer supplied as a parameter
#* is online; false otherwise
#*=============================================
#* See also:
#* Ping Class - Allows an application to determine whether
#* a remote computer is accessible over the network.
#* http://msdn.microsoft.com/en-us/library/system.net.networkinformation.ping.aspx
#*
#* PingReply Class - Provides information about the status
#* and data resulting from a (Ping) Send or SendAsync operation.
#* http://msdn.microsoft.com/en-us/library/system.net.networkinformation.pingreply.aspx
#*=============================================
function Ping {
[cmdletbinding()]
Param (
    [parameter(Mandatory=$true,
               Position=0)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ComputerName
) #end param

  [Int32]$timeout = 4000;
  [Boolean]$retval = true;
  trap { continue; }

  $ping = New-Object -TypeName System.Net.NetworkInformation.Ping;
  $reply = New-Object -TypeName System.Net.NetworkInformation.PingReply;

  # -> hostNameOrAddress
  # A String that identifies the computer that is the destination
  # for the ICMP echo message.
  # -> timeout
  # An Int32 value that specifies the maximum number of milliseconds
  # (after sending the echo message) to wait for the ICMP echo reply
  # message.
  Write-Verbose -Message "Pinging the computer with a timeout of $timeout milliseconds";
  $reply = $ping.Send($ComputerName, $timeout);

  if( $reply.Status -eq "Success"  )
  {
     $retval = $true;
  }
  else
  {
     $retval = $false;
  }

  Write-Verbose -Message "Returning from function Ping with a value of $retval";
  return $retval;

} # end of Ping
#endregion ********** end of function ping **********

#----------------------------------------------------------

#region ***** function Show-OracleSvcs *****
##=============================================
## Function: Show-OracleSvcs
## Created: 2013-06-05
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: displays Oracle related MS Windows processes,
## running or not.
## Returns: N/A
##=============================================
## See also:
## Using the Get-Service Cmdlet
## http://technet.microsoft.com/en-us/library/ee176858.aspx
##
## The Get-Service cmdlet gets objects that represent the services
## on a local computer or on a remote computer, including running
## and stopped services.
## http://technet.microsoft.com/library/hh849804.aspx
##=============================================
function Show-OracleSvcs {
[CmdletBinding()]
Param() #end param

  $svcStopped = 0;
  $svcRunning = 0;

  #Write-Output "Looking for Oracle services (if any)";
  $colItems = Get-Service -Name 'Oracle*';

  # Column headers.
  Write-Output "";
  Write-Output ("{0}      {1}" -f "Status", "Name");
  Write-Output ("{0}      {1}" -f "------", "----");

  foreach ($item in $colItems) {
      if ($item.Status -eq 'Running')
      {
          $fColor = "Green";
          $svcRunning++;
      }
      else
      {
          $fColor = "Red";
          $svcStopped++;
      }
      Write-Host ("{0}     {1}" -f $item.Status, $item.Name) -ForegroundColor $fColor;
  }

  if (($svcStopped + $svcRunning) -eq 0) {
     Write-Warning -Message "No Oracle related services found";
  } else {
     $hash = @{
        Running = $svcRunning
        Nonrunning = $svcStopped
     }
     $totals = New-Object PSObject -Property $hash;
     Out-String -InputObject $totals -Width 22;
  }

}
#endregion ***** end of function Show-OracleSvcs *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## MAIN ROUTINE STARTS HERE
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Oracle related MS Windows services';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output "Looking for Oracle services on computer $ComputerName";
if (Ping($ComputerName)) {
  Show-OracleSvcs;
} else {
  Write-Warning -Message "Computer $ComputerName appears to be offline";
}
Write-Verbose -Message "All done now!";
##=============================================
## END OF SCRIPT: Show-OracleServices.ps1
##=============================================
