<#
.SYNOPSIS

Displays active TCP connections

.DESCRIPTION

Processes the output from the command "NETSTAT.EXE -no -p tcp" to
show 'ESTABLISHED' connections on the server. Of particular
interest is the IP address shown in column 'foreign address' as
this shows us which servers to connected to the server where we
obtained these netstat statistics. A DNS lookup is done to obtain
the server name by calling the System.Net.Dns class. Only IPv4
addresses are processed.

Netstat provides statistics under the following columns:

Proto   Local Address   Foreign Address   State   PID

o Proto
The name of the protocol (TCP or UDP). In our case we're only
interested in TCP connections.

o Local Address
The IP address of the local computer and the port number being
used. ie, 192.6.1.101:105.

o Foreign Address
The IP address and port number of the remote computer to which
the socket is connected. ie, 16.12.44.10:505

o State
Indicates the state of a TCP connection. As we're only interested
'ESTABLISHED' connections this will always be ESTABLISHED.

o PID - Process ID of of the process involved with this connection.
You can find the application based on the PID on the Processes tab
in Windows Task Manager.


.EXAMPLE

./Get-NetstatPno.ps1

No parameters are required

Sample output:

Socket# 1

Protocol        : TCP
Local Address   : 19.3.1.12:1334
Foreign Address : 5.67.15.5:5874 (HOST NAME UNKNOWN)
State           : ESTABLISHED
Process Name    : svchost

Socket# 2
Protocol        : TCP
Local Address   : 74.3.1.85:5485
Foreign Address : 6.18.83.7:3285 (HOST NAME UNKNOWN)
State           : ESTABLISHED
Process Name    : svchost

Socket# 3
Protocol        : TCP
Local Address   : 41.43.1.12:7389
Foreign Address : 21.56.83.3:3307 (HOST NAME UNKNOWN)
State           : ESTABLISHED
Process Name    : svchost

All done now. 3 sockets listed


.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Get-NetstatPno.ps1
Author       : Ian Molloy
Last updated : 2019-05-29
Keywords     : netstat tcp connection server ip address

.LINK

netstat
Displays active TCP connections, ports on which the computer is listening
https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/netstat

MatchInfo Class
Namespace:
Microsoft.PowerShell.Commands
https://docs.microsoft.com/en-us/dotnet/api/microsoft.powershell.commands.matchinfo?view=powershellsdk-1.1.0

MatchInfo.Matches Property
Namespace:
Microsoft.PowerShell.Commands
https://docs.microsoft.com/en-us/dotnet/api/microsoft.powershell.commands.matchinfo.matches?view=powershellsdk-1.1.0#Microsoft_PowerShell_Commands_MatchInfo_Matches

Match Class
Namespace:
System.Text.RegularExpressions
https://docs.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.match?redirectedfrom=MSDN&view=netframework-4.8

#>


[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [String]
   $NetstatDatafile
) #end param

#region ***** Function Get-Hostname2 *****
function Get-Hostname2 {
<#
.SYNOPSIS
Does a DNS lookup on the IP address supplied

.DESCRIPTION
The IP address supplied is used do a DNS lookup using the
System.Net.Dns class. This is done asynchronously allowing
us to implement a timeout of X milliseconds.

Of course, there is no guarantee we can resolve the IP
address to an IPHostEntry instance. If this happens, the
string "HOST NAME UNKNOWN" will be returned.

.PARAMETER IpAddress
The IP address to resolve to a host name.

#>

[CmdletBinding()]
[OutputType([System.String])]
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="Foreign Address")]
        [ValidateNotNullOrEmpty()]
        [String]$IpAddress
      ) #end param

  $timeout = 750; # milliseconds timeout
  $iasyncresult = [System.Net.Dns]::BeginGetHostEntry($IpAddress, $null, $null);
  $response = $iasyncresult.AsyncWaitHandle.WaitOne($timeout, $true);

  if ($response)
  {
      # Returns a TypeName: System.Net.IPHostEntry object
      $result = [System.Net.Dns]::EndGetHostEntry($iasyncresult);
      $retval = $result.HostName;
  }
  else
  {
      $retval = 'HOST NAME UNKNOWN';
  }

  return $retval;
}
#endregion ***** End of function Get-Hostname2 *****

#region ***** Function Get-Hostname *****
function Get-Hostname {
<#
.SYNOPSIS
Extract the IP address from the foreign address string

.DESCRIPTION
The foreign address string passsed in consists of the IP address
and the port being used. ie. 6.18.83.7:3285. This function will
extract the IP address (only) so that the next function can do a
DNS lookup.

.PARAMETER ForeignAddress
The foreign address from which to extract the IP address.

#>

[CmdletBinding()]
[OutputType([System.String])]
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="Foreign Address")]
        [ValidateNotNullOrEmpty()]
        [String]$ForeignAddress
      ) #end param

  $IPv4_regex = "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}";
  $m = $ForeignAddress | Select-String -Pattern $IPv4_regex;

  if ($m.Matches.Success) {
    # We've managed to extract the IPv4 IP address from
    # the foreign address. Now do a DNS lookup on this
    # address to see what the host name is.
    $retval = Get-Hostname2 -IpAddress $m.Matches.Value;
  } else {
    $retval = 'HOST NAME UNKNOWN';
  }

  return $retval;
}
#endregion ***** End of function Get-Hostname *****


##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

[String]$hname = '';

Clear-Host;

if ($PSBoundParameters.ContainsKey('NetstatDatafile')) {
   # A file containing netstat data has been supplied.
   # Lets use that.
   Write-Output "Reading netstat data from file: $($NetstatDatafile)";
   $data = Get-Content $NetstatDatafile -ReadCount 128;
} else {
   # As we don't have a data file to work with, lets grab
   # our own netstat date.
   $data = NETSTAT.EXE -n -o -p tcp;
}

# The Where-Object cmdlet is used to filter out IPv4 addresses
# that have a state of 'ESTABLISHED'.
$data | Where-Object {($_ -match 'ESTABLISHED') -and ($_.IndexOf('.') -gt 0 )} |
ForEach-Object -Begin {$Counter = 0} `
-Process {
    $SplitLine = $_.Trim() -split '\s+';
    Write-Debug -Message "About to call function with foreign address $($SplitLine[2])";
    $hname = Get-Hostname -ForeignAddress $SplitLine[2];
    $Counter++;
    Write-Output ('Socket# {0}' -f $Counter);
    $obj = [PSCustomObject][ordered]@{
        'Protocol' = $SplitLine[0];
        'Local Address' = $SplitLine[1];
        #'Foreign Address' = $SplitLine[2];
        'Foreign Address' = ("{0} ({1})" -f $SplitLine[2], $hname);
        'State' = $SplitLine[3];
        'Process Name' = $(Get-Process -Id $SplitLine[4]).ProcessName;
    } #end of PSCustomObject
    Write-Output $obj;
} `
-End {Write-Output ('All done now. {0} sockets listed' -f $Counter);}

##=============================================
## END OF SCRIPT: Get-NetstatPno.ps1
##=============================================
