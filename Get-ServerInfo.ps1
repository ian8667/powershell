<#
.SYNOPSIS

Shows server related information

.DESCRIPTION

Lists various server related information such as:
    o O/S architecture and last boot time.
    o Oracle related MS Windows processes (if any).
    o Disk space information.

.PARAMETER ComputerName

The name of the computer that you wish to obtain information for.
An error message is generated if the computer is not online.

This is a mandatory parameter.

.EXAMPLE

./Get-ServerInfo.ps1 localhost

A positional parameter has been supplied so information for this
computer will be listed.

.EXAMPLE

./Get-ServerInfo.ps1 -ComputerName localhost

Using a named parameter to supply the computer name for which
information will be listed.

.EXAMPLE

./Get-ServerInfo.ps1

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

File Name    : Get-ServerInfo.ps1
Author       : Ian Molloy
Last updated : 2020-08-04T15:18:35

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
               HelpMessage="Enter the computer name to check",
               Position=0)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ComputerName
) #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function Show-OsInfo *****
##=============================================
## Function: Show-OsInfo
## Created: 2013-05-27
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: displays OS related information.
## Returns: N/A
##=============================================
## See also: Using the Get-Service Cmdlet
## http://technet.microsoft.com/en-us/library/ee176858.aspx
##=============================================
function Show-OsInfo {
[CmdletBinding()]

   $params=@{
      ComputerName = $ComputerName
      Class = 'Win32_OperatingSystem'
   }
   $win32OS = Get-WmiObject @params;

   $OS = $win32OS.Caption;

   if ($win32OS.OSArchitecture -eq '64-bit') {
      $architecture = "64-Bit";
   } else  {
      $architecture = "32-Bit";
   }

   $sType = (Get-WmiObject -ComputerName $ComputerName -Class win32_computersystem).SystemType;

   # Obtain the last boot time.

   # The value returned is in the format of "20130509201352.276367+060".
   $dd = $win32OS.LastBootUpTime;
   # [Management.ManagementDateTimeConverter]::ToDateTime($operatingSystem.LastBootUpTime) or
   # $RebootTime = [System.DateTime]::ParseExact($dd.split(".")[0],'yyyyMMddHHmmss',$null)
   $RebootTime = $win32OS.ConvertToDateTime($win32OS.LastBootUpTime);

   $TimeSpan = New-TimeSpan -Start $RebootTime -End (Get-Date)

<#
 $obj = New-Object -TypeName psobject
 $obj | Add-Member -MemberType noteproperty -Name ComputerName -Value $ComputerName.ToUpper();
 $obj | Add-Member -MemberType noteproperty -Name Architecture -Value $architecture;
 $obj | Add-Member -MemberType noteproperty -Name OperatingSystem -Value $OS;
 $obj | Add-Member -MemberType noteproperty -Name SystemType -Value $sType;
 $obj | Add-Member -MemberType noteproperty -Name LastBoottime -Value $RebootTime.ToString("dddd dd MMM yyyy HH:mm");
 Write-output $obj
#>

   $hash = [ordered]@{
        ComputerName     = $ComputerName.ToUpper()
        Architecture     = $architecture
        OperatingSystem  = $OS
        SystemType       = $sType
        LastBoottime     = $RebootTime.ToString("dddd dd MMM yyyy HH:mm")
   }
   $OutputObj = New-Object PSObject -Property $hash;
   Write-Output $OutputObj;

   Write-Output "Elpased time since last reboot:";
   Write-Output ("{0:00} days {1:00} hours {2:00} minutes {3:00} seconds" -f
                 $TimeSpan.Days,
                 $TimeSpan.Hours,
                 $TimeSpan.Minutes,
                 $TimeSpan.Seconds);

   $dd = Get-Date -Format "dddd, dd MMMM yyyy HH:mm"
   Write-Output "Current date/time: $dd";

}
#endregion ***** end of function Show-OsInfo *****

#----------------------------------------------------------

#region ***** function Show-OracleProcesses *****
##=============================================
## Function: Show-OracleProcesses
## Created: 2013-05-25
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: displays Oracle related processes, running
## or not.
## Returns: N/A
##=============================================
## See also: Using the Get-Service Cmdlet
## http://technet.microsoft.com/en-us/library/ee176858.aspx
##=============================================
function Show-OracleProcesses {
[CmdletBinding()]

  $svcStopped = 0;
  $svcRunning = 0;

  Write-Output "Looking for Oracle services (if any)";
  $colItems = Get-Service -Name Oracle*;

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
      Write-Output ("{0}     {1}" -f $item.Status, $item.Name) -ForegroundColor $fColor;
  }

  # Shall I try this approach?
  $hash = @{
     Running = $svcRunning
     Nonrunning = $svcStopped
  }
  $totals = New-Object PSObject -Property $hash;
  Out-String -InputObject $totals -Width 22;

  Write-Output "";
  Write-Output "Running processes: $svcRunning";
  Write-Output "Non-running processes: $svcStopped";

}
#endregion ***** end of function Show-OracleProcesses *****

#----------------------------------------------------------

#region ***** function Get-Script-Info *****
##=============================================
## Function: Get-Script-Info
## Created: 2013-05-25
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: displays the script name and folder from
## where the script is running from.
## Returns: N/A
##=============================================
function Get-Script-Info {
[CmdletBinding()]

   if ($MyInvocation.ScriptName) {
       $p1 = Split-Path -Leaf $MyInvocation.ScriptName;
       $p2 = Split-Path -Parent $MyInvocation.ScriptName;
       Write-Host "`nExecuting script ""$p1"" in folder ""$p2""";
   } else {
      $MyInvocation.MyCommand.Definition;
   }

}
#endregion ***** end of function Get-Script-Info *****

#----------------------------------------------------------

#region ***** function PrintBlankLines *****
#*=============================================
#* Function: PrintBlankLines
#* Created: 2013-05-25
#* Author: Ian Molloy
#* Arguments: Lines - the number of blank line to print
#*=============================================
#* Purpose:
## Prints the specified number blank line to to screen.
#* Returns:
#* N/A
#*=============================================
function PrintBlankLines {
[CmdletBinding()]
param (
    [parameter(Position=0,
               Mandatory=$true)]
    [ValidateRange(1,15)]
    [Int32]$lines
) #end param

  $myarray = 1..$lines;
  for ($m=0; $m -lt $myarray.length; $m++) {
     $myarray[$m] = ' ';
  }
  Write-Output $myarray;
  
}
#endregion ***** end of function PrintBlankLines *****

#----------------------------------------------------------

#region ***** function Get-DiskSpace *****
##=============================================
## Function: Get-DiskSpace
## Created: 2013-05-25
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: displays disk space for the computer being checked.
## Returns: N/A
##=============================================
function Get-DiskSpace {
[CmdletBinding()]

  New-Variable -Name spaceUnit -Value "1GB" -Option Constant;

  $dtype = DATA {
  ConvertFrom-StringData -StringData @'
    0 = Unknown
    1 = No Root Directory
    2 = Removable Disk
    3 = Local Disk
    4 = Network Drive
    5 = Compact Disk
    6 = RAM Disk
'@
  }

  # DeviceID - unique identifier of the logical disk from other
  # devices on the system (ie drive name).
  $name = @{
    Name = 'Drive'
    Expression = { $_.DeviceID }
  }

  # Size - size of the disk drive.
  $size = @{
    Name = 'Alloc'
    Expression = { '{0:#,##0.0} GB' -f ($_.Size / $spaceUnit) }
  }

  # FreeSpace - the space, in bytes, available on the logical disk.
  $free = @{
    Name = 'Free'
    Expression = { '{0:#,##0.0} GB' -f ($_.FreeSpace / $spaceUnit) }
  }

  # Disk space used.
  $used = @{
    Name = 'Used'
    Expression = { '{0:#,##0.0} GB' -f (($_.Size - $_.FreeSpace) / $spaceUnit) }
  }

  # percent free
  $pcfree = @{
    Name = '% free'
    Expression = { '{0:P0}' -f ($_.FreeSpace / $_.Size) }
  }

  # percent used
  $pcused = @{
    Name = '% used'
    Expression = { '{0:P0}' -f (($_.Size - $_.FreeSpace) / $_.Size) }
  }

  $drivetype = @{
    Name = "Drive Type"
    Expression = {$dtype["$($_.DriveType)"]}
  }

  # Parameters supplied to the Get-WMiObject Cmdlet.
  # See also: http://technet.microsoft.com/en-us/library/ee176860.aspx
  $params = @{
    'Class' = 'Win32_LogicalDisk'
    'Filter' = 'DriveType=3'
    'Namespace' = 'root/cimv2'
    'Computername' = $ComputerName
  }

  Get-WmiObject @params |
      Select-Object -Property $name, $drivetype, $size, $free, $used, $pcfree, $pcused | Format-Table

}
#endregion ***** end of function Get-DiskSpace *****

#----------------------------------------------------------

#region ***** function ping *****
#*=============================================
#* Function: Ping
#* Created: 2013-05-25
#* Author: Ian Molloy
#* Arguments: ComputerName - the computer to check
#*=============================================
#* Purpose:
## Determines whether the computer is online or not.
#* Returns:
#* true if and only if the computer supplied as a parameter
#* is online; false otherwise
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

  [Int32]$timeout = 2000;
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

  return $retval;

} # end of Ping
#endregion ***** end of function ping *****

#----------------------------------------------------------

#region ***** function main_routine *****
##=============================================
## Function: main_routine
## Created: 2013-05-25
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: main helper function to gather all
## other function calls together.
## Returns: N/A
##=============================================
function main_routine {
[CmdletBinding()]

  if ($PSBoundParameters['Verbose']) {
     Write-Host "doing some verbose things";
     Write-Host "this is mighty fun";
  }

  if (Ping($ComputerName)) {

    Get-Script-Info;

    Show-OracleProcesses;

    Get-DiskSpace;
    
    Show-OsInfo;
  } else {
    Write-Warning "Computer $ComputerName is not online";
  }

}
#endregion ***** end of function main_routine *****

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
   Write-Output 'Server information';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

main_routine;
##=============================================
## END OF SCRIPT: Get-ServerInfo.ps1
##=============================================
