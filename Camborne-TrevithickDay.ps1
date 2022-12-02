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
Last updated : 2022-12-02T19:26:51


TimeOnly and DateOnly Struct (Namespace: System).

DateTime.Now Property
An object whose value is the current local date and time.
DateTime.Today Property
An object that is set to today's date, with the time component set to 00:00:00.

To get current date only:
$dateNow = [System.DateOnly]::FromDateTime([System.DateTime]::Today);
To get current time only:
$timeNow = [System.TimeOnly]::FromDateTime([System.DateTime]::Now);

.LINK

https://trevithickday.org.uk/?utm_medium=referral&utm_source=visitcornwall.com&utm_campaign=listing

https://cornishnationalmusicarchive.co.uk/content/trevithick-day/

https://www.facebook.com/TrevithickDay

https://www.cornwalls.co.uk/events/trevithick-day

https://cambornecommunitychurch.org.uk/community/trevithick-day

Math.Clamp Method
#>

[CmdletBinding()]
Param() #end param

#----------------------------------------------------------
# Start of delegates
#----------------------------------------------------------

[Func[Int32,DateTime]]$Get_TrevithickDate = {
param($TheYear)

#Our day of interest. Always a Saturday
$saturday = [System.DayOfWeek]::Saturday;

#Our month (number) of interest. Always April
$april = 04;

#Admittedly, April should always have 30 days so this already
#known to us. But this shows you can find the number of days
#in a month if you wish to
$DaysInMonth = [System.DateTime]::DaysInMonth($TheYear, $april) #year, month

#Initialise the variable to the last day in April for the
#year passed in as a parameter
$TempDate = Get-Date -Year $TheYear -Month  $april -Day $DaysInMonth;
Set-Variable -name 'saturday', 'april' -Option ReadOnly;

while ($TempDate.DayOfWeek -ne $saturday) {
   # Go backwards from the end of the month until
   # we get to the first Saturday.
   $TempDate = $TempDate.AddDays(-1);
}

# Return the date found
$TempDate;
} #end Func

#----------------------------------------------------------

[Func[String]]$TrevithickDay_Message = {
  # Brief explanation of Camborne Trevithick Day
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
     Write-Output "Camborne Trevithick Day for the next couple of years";
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
Set-Variable -Name 'dateMask' -Option ReadOnly;

$CurrentYear = (Get-Date).year;
Set-Variable -Name 'CurrentYear' -Option ReadOnly;

#Find Trevithick Day for the current year plus the
#next four years (five years in total)
foreach ($year in $CurrentYear..($CurrentYear+4)) {
  $TrevDay = $Get_TrevithickDate.Invoke($year);
  Write-Output ('Trevithick Day for the year {0} is {1}' -f $year,$TrevDay.ToString($dateMask));
}

Write-Output '';
Write-Output 'End of list';

##=============================================
## END OF SCRIPT: Camborne-TrevithickDay.ps1
##=============================================
