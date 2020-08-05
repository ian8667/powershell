############################################################
## Carries out some tests against a target which has been
## identified by a Grid Control alert as a bit suspect.
##
## This script only works with Windows machines.
##
## Parameters:
## ComputerName - the hostname to check.
##
## Last updated: 2020-08-04T16:23:11
############################################################
Param (
    [parameter(Mandatory=$true,
               HelpMessage="Enter the remote computer name",
               Position=0)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ComputerName
) #end param

#################################################

$namespace = "root\CIMV2"
$snags=$false

#################################################

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#
# Prints a character a number of times on the same line.
# Parameters:
# char - the character to print.
# num - the number of times the character shall be printed.
#
function printcharacter {
[CmdletBinding()]

param([string]$char, [Int32]$num)
  foreach ($cc in 1..$num) {Write-Host $char -NoNewline}
  $host.UI.WriteLine()
}

#----------------------------------------------------------

#
# Prints a title with a line of characters above and below
# the title printed.
# Parameters:
# title - the title to print.
#
function printtitle {
[CmdletBinding()]
param([string]$title)
  $len=$title.length
  printcharacter "=" $len
  Write-Host $title
  printcharacter "=" $len
}

#----------------------------------------------------------

#
# Prints blank lines.
# Parameters:
# lines - the number of blank lines to print.
#
function blanklines {
[CmdletBinding()]
param([Int32]$lines)
  # or $host.UI.WriteLine() ?
  # or [console]::WriteLine() ?
  foreach ($num in 1..$lines) {$host.UI.WriteLine()}
}

#----------------------------------------------------------

#
# Carries out the checks required.
#
function doChecks {
[CmdletBinding()]

  #
  # Ping the hostname given.
  #

  blanklines 3
  printtitle "Check 1 - ping the host"

  $ping = get-wmiobject -Query "select * from Win32_PingStatus where   Address='$computer'"
  Start-Sleep -Seconds 1
  # Display Results
  if ($ping.statuscode -eq 0) {
     "Host $computer responded in:  {0} ms" -f $ping.responsetime
  } else {
     write-host "No response from computer $computer" -Foregroundcolor Red
     $snags=$true
  }


  #
  # List Oracle services running (if any) on the hostname given.
  #

  blanklines 3
  printtitle "Check 2 - Oracle services running on the host"

  Get-WmiObject -class win32_service -computername $computer -namespace $namespace |
         where {$_.Name -like "Oracle*"} |
         select-object Name, State, Status, StartMode |
         Format-Table Name, State, Status, StartMode -AutoSize | Out-Default


  #
  # Lists disc space for the host.
  #

  blanklines 3
  printtitle "Check 3 - available disc space"

  Get-WmiObject -class win32_logicaldisk -computer $computer  | `
      Format-Table SystemName, Name, VolumeName, `
      @{Label="Size(Gb)"; Expression={($_.size/1gb).tostring("F03")}}, `
      @{Label="Freespace(Gb)"; Expression={($_.freespace/1gb).tostring("F03")}} `
          -AutoSize | Out-Default


  blanklines 3
  printtitle "Check 4 - List of local users"

  #
  # List Local Users on the remote computer
  #
  $strComputer = $computer

  $computer = [ADSI]("WinNT://" + $strComputer + ",computer")
  $computer.name

  $Users = $computer.psbase.children | where{$_.psbase.schemaclassname -eq "User"}

  foreach ($member in $Users.psbase.syncroot)
  {$member.name}


  #
  # Last boot time for the host.
  #

  # I'm not able to run 'Get-WmiObject -class Win32_OperatingSystem
  # -property LastBootUpTime' to obtain the last boottime for a server
  # without receiving the error:
  #   "Get-WmiObject : The RPC server is unavailable".
  #
  #$wmi = Get-WmiObject -Class Win32_OperatingSystem -Computer "."
  #$wmi.ConvertToDateTime($wmi.LastBootUpTime)
  #
  # Looking at the Internet a lot of people are having this problem.
  # The only known way around this is to run from the prompt:
  # Powershell:
  # Get-WmiObject -class Win32_OperatingSystem -property LastBootUpTime
  # [System.Management.ManagementDateTimeConverter]::ToDateTime('20100510080437.461482+060')
  #
  # DOS:
  # net statistics workstation | find /i "Statistics since"
  # or
  # wmic /node:HQTTOPUSDB04 os get lastbootuptime
  # or
  # dir c:\pagefile.sys /ah

}

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Carry out some tests on the selected server';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

doChecks;

blanklines 2
Write-Output "All done now for host $computer!";

##=============================================
## END OF SCRIPT: gridchecks.ps1
##=============================================
