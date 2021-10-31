<#
.SYNOPSIS

List of Camborne Trevithick Day's

.DESCRIPTION

Camborne Trevithick Day, always held on the last Saturday of
April, celebrates the engineering and mining history of the
Camborne area, and is dedicated to Richard Trevithick, pioneer
of high pressure steam power and inventor of Road and Railway
Locomotives.

This program lists Camborne Trevithick Day for the current
year plus the next four (ie, five years in total). Depending
on when you run this program, Camborne Trevithick Day for the
current year may well have passed.

.EXAMPLE

./Camborne-TrevithickDay.ps1

No parameters are used

Sample output

Trevithick day for 2021 is Saturday, 24 April
Trevithick day for 2022 is Saturday, 30 April
Trevithick day for 2023 is Saturday, 29 April
Trevithick day for 2024 is Saturday, 27 April
Trevithick day for 2025 is Saturday, 26 April

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Camborne-TrevithickDay.ps1
Author       : Ian Molloy
Last updated : 2021-10-31T20:24:28

.LINK

https://trevithickday.org.uk/?utm_medium=referral&utm_source=visitcornwall.com&utm_campaign=listing

https://cornishnationalmusicarchive.co.uk/content/trevithick-day/

https://www.facebook.com/TrevithickDay

https://www.cornwalls.co.uk/events/trevithick-day

https://cambornecommunitychurch.org.uk/community/trevithick-day

#>

[CmdletBinding()]
Param ( ) #end param

#----------------------------------------------------------
# Start of delegates
#----------------------------------------------------------

[Func[Int32,DateTime]]$Get_TrevithickDate = {
param($x)

$saturday = [System.DayOfWeek]::Saturday;
$year = $x;
$april = 4;
$TempDate = Get-Date -Year $year -Month  $april -Day 30;
Set-Variable -name 'saturday', 'year','april' -Option ReadOnly;

while ($TempDate.DayOfWeek -ne $saturday) {
   # Go backwards from the end of the month until
   # we get to a Saturday.
   $TempDate = $TempDate.AddDays(-1);
}

$TempDate;
} #end Func

#----------------------------------------------------------

[Func[String]]$TrevithickDay_Message = {
  $message = @"
  Camborne Trevithick Day

  The day, always held on the last Saturday of April, celebrates
  the engineering and mining history of the Camborne area, and
  is dedicated to Richard Trevithick, pioneer of high pressure
  steam power and inventor of Road and Railway Locomotives.

  Richard Trevithick pioneered the use of high-pressure steam
  for use in the mines and in 1801 he built a full-size,
  steam, road locomotive on a site near present-day Fore Street
  in Camborne. He named it "Puffing Devil" and on Christmas Eve
  it began its first epic journey by ascending Fore Street
  (Camborne Hill). It was the world's first demonstration of
  a steam-powered road vehicle.

  Camborne is located on the main A30 through Cornwall, and
  on Trevithick Day the main streets are closed to traffic in
  order to host the attractions.

  Details:
  event.office@trevithick-day.org.uk
  07501 436 091
  Trevithick Day
  Bassett Street
  Camborne
  Cornwall TR14 8SU
"@

  $message;
}

#----------------------------------------------------------
# End of delegates
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {
  <#
  $MyInvocation
  TypeName: System.Management.Automation.InvocationInfo
  This automatic variable contains information about the current
  command, such as the name, parameters, parameter values, and
  information about how the command was started, called, or
  invoked, such as the name of the script that called the current
  command.

  $MyInvocation is populated differently depending upon whether
  the script was run from the command line or submitted as a
  background job. This means that $MyInvocation may not be able
  to return the path and file name of the script concerned as
  intended.
  #>
     Write-Output '';
     Write-Output "Camborne Trevithick Day for the next couple of yesrs";
     $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
     Write-Output ('Today is {0}' -f $dateMask);

     if ($MyInvocation.OffsetInLine -ne 0) {
         #I think the script was run from the command line
         $script = $MyInvocation.MyCommand.Name;
         $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
         Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);
     }

} #end of Invoke-Command -ScriptBlock

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output $TrevithickDay_Message.Invoke();
[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
[System.Linq.Enumerable]::Repeat("", 2); #blanklines

$dateMask = 'dddd, dd MMMM';
$yy = (Get-Date).year;
foreach ($year in $yy..($yy+4)) {
  $result = $Get_TrevithickDate.Invoke($year);
  Write-Output ('Trevithick day for {0} is {1}' -f $year,$result.ToString($dateMask));
}

Write-Output 'End of list';

##=============================================
## END OF SCRIPT: Camborne-TrevithickDay.ps1
##=============================================
