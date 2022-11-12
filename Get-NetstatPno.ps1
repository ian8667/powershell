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

.EXAMPLE

./Get-NetstatPno.ps1 netstatdatefile.txt

Using a positional parameter notation, specifies the path to
a text file containing netstat data.

Sample output as above.

.EXAMPLE

./Get-NetstatPno.ps1 -NetstatDatafile netstatdatefile.txt

Using a named parameter notation, specifies the path to
a text file containing netstat data.

Sample output as above.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Get-NetstatPno.ps1
Author       : Ian Molloy
Last updated : 2022-11-01T15:12:27
Keywords     : netstat tcp connection server ip address

$iasyncresult = TypeName: System.Threading.Tasks.TaskToApm+TaskAsyncResult
$iasyncresult.AsyncWaitHandle = TypeName: System.Threading.ManualResetEvent

The WaitHandle is signaled when the asynchronous call
completes, and you can wait for it by calling the
WaitOne method.

'WaitOne()' is a method of System.Threading.WaitHandle Class
and blocks the current thread until the current WaitHandle receives
a signal, using a 32-bit signed integer to specify the time
interval. The return type from boolean method WaitOne is true if
the current instance receives a signal; otherwise, false.

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

System IAsyncResult Interface
https://docs.microsoft.com/en-us/dotnet/api/system.iasyncresult?view=netcore-3.1

System IAsyncResult.AsyncWaitHandle Property
https://docs.microsoft.com/en-us/dotnet/api/system.iasyncresult.asyncwaithandle?view=netcore-3.1#System_IAsyncResult_AsyncWaitHandle

Gathering Network Statistics with PowerShell
https://devblogs.microsoft.com/scripting/gathering-network-statistics-with-powershell/

System.Diagnostics.Process Class
https://docs.microsoft.com/en-us/dotnet/api/system.diagnostics.process?view=net-6.0

WaitOne(Int32, Boolean)
https://docs.microsoft.com/en-us/dotnet/api/system.threading.waithandle.waitone?view=netcore-3.1#System_Threading_WaitHandle_WaitOne_System_Int32_System_Boolean_

Interesting to see that in this web site, they use similiar code as I
use for variable '$response'. Is this how '$iasyncresult' should be
used?
measure-command { $succ = $iasyncresult.AsyncWaitHandle.WaitOne(3000, $true) } |
 % totalseconds
https://www.powershelladmin.com/wiki/Check_for_open_TCP_ports_using_PowerShell

#####
$Process01 = @{
  Name = 'ProcessName'
  Expression = { (Get-Process -Id $_.OwningProcess).Name }
}

$Process02 = @{
  Name = 'ProcName'
  Expression = {
    # Get the process path
    Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName
  }
}

$Process03 = @{
  Name = 'Path'
  Expression = {
    # Get the process path
    Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Path
  }
}

$darkAgent = @{
  Name = 'ExternalIdentity'
  Expression = {
    $ip = $_.RemoteAddress
    (Invoke-RestMethod -Uri "http://ipinfo.io/$ip/json" -UseBasicParsing -ErrorAction Ignore).org

  }
}
Get-NetTCPConnection -RemotePort 443 -State Established |
  Select-Object -Property RemoteAddress, OwningProcess, $process, $darkAgent;
Source: https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/identifying-origin-of-network-access
#####

Outgoing connections

$procid = @{Name='ID'; Expression={$_.OwningProcess}}
$procname = @{Name='Process'; Expression={(Get-Process -Id $_.OwningProcess).Name}}
Set-Variable -Name 'procid', 'procname' -Option ReadOnly;

Get-NetTCPConnection -State Established |
Select-Object -Property RemoteAddress, RemotePort, $procid, $procname;

#>

<#
new work:
o refactor the code to use PowerShell cmdlets instead of netstat
o upload to github
#>
[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [String]
   $NetstatDatafile
) #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

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

  [Int32]$timeout = 750; # The number of milliseconds to wait
  $iasyncresult = [System.Net.Dns]::BeginGetHostEntry($IpAddress, $null, $null);
  $response = $iasyncresult.AsyncWaitHandle.WaitOne($timeout, $true);

  if ($response) {
      # Returns a TypeName: System.Net.IPHostEntry object
      $result = [System.Net.Dns]::EndGetHostEntry($iasyncresult);
      $retval = $result.HostName;

      $iasyncresult.AsyncWaitHandle.Close();
    } else {
      $retval = 'HOST NAME UNKNOWN';
  }

  return $retval;
}
#endregion ***** End of function Get-Hostname2 *****

#----------------------------------------------------------

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

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Clear-Host;

[String]$hname = '';

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'netstat and active TCP connections';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

if ($PSBoundParameters.ContainsKey('NetstatDatafile')) {
   # A file containing netstat data has been supplied.
   # Lets use that.
   Write-Output "Reading netstat data from file: $($NetstatDatafile)";
   $data = Get-Content $NetstatDatafile -ReadCount 128;
} else {
   # As we don't have a data file to work with, lets grab
   # our own netstat data.
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
