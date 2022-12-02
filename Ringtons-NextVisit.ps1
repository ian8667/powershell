<#

.SYNOPSIS

Show when Ringtons tea van is next due

.DESCRIPTION

Increments in steps of 14 days (two weeks) the date from a known
start date to determine when the Ringtons tea van is next due.

The 'System.DateOnly' type is used within this program given that
we're just dealing with dates between each Ringtons visit.
The DateOnly type is a structure that is intended to represent
only a date. In other words, just a year, month, and day.

.EXAMPLE

./Ringtons-NextVisit.ps1

No parameters required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Ringtons-NextVisit.ps1
Author       : Ian Molloy
Last updated : 2022-12-02T19:39:13

Ringtons Ltd, Algernon Road, Newcastle upon Tyne, NE6 2YN
Tel: 0800 052 2440
Email: tea@ringtons.co.uk


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

https://www.ringtons.co.uk/

"Date, Time, and Time Zone Enhancements in .NET 6"
https://devblogs.microsoft.com/dotnet/date-time-and-time-zone-enhancements-in-net-6/

#>

[CmdletBinding()]
Param() #end param

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
   Write-Output "Date of Ringtons tea van next visit";
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy';
   Write-Output ('Today is {0}' -f $dateMask);

   if ($MyInvocation.OffsetInLine -ne 0) {
       #I think the script was run from the command line
       $script = $MyInvocation.MyCommand.Name;
       $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
       Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);
   }

} #end of Invoke-Command -ScriptBlock

$dateMask = 'dddd, dd MMMM yyyy';
Set-Variable -Name 'dateMask' -Option ReadOnly;
# Start date from which we will start our looping
$startDate = [System.DateOnly]::new(2022, 01, 19); # year, month, day
# Create a 'System.DateOnly' object with current date
$endDate = [System.DateOnly]::FromDateTime($(Get-Date));
$DaysToAdd = 14; #ie, every two weeks
Set-Variable -Name 'startDate', 'endDate', 'DaysToAdd' -Option ReadOnly;

Write-Verbose -Message ("Start date used: {0}" -f $startDate.ToString($dateMask));
# Loop in multiples of 14 days from the start date. This will
# enable us to determine the next visit date. Potentially,
# depending on when the next Ringtons visit is due, variable
# '$tempDate' may well be several days into the future when
# the loop terminates and is the date when Ringtons is next
# due to visit.
$tempDate = $startDate;
do {
    $tempDate = $tempDate.AddDays($DaysToAdd);
} until ($tempDate.CompareTo($endDate) -ge 0);

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output ('Ringtons next visit is on {0}' -f $tempDate.ToString($dateMask));
#$Difference = New-TimeSpan -Start $endDate -End $tempDate;
$Difference = $tempDate.DayNumber - $endDate.DayNumber;

if ($Difference -eq 0) {
    Write-Warning -Message 'Which is today!';
} else {
    Write-Output ('In {0} days time' -f $Difference);
}

##=============================================
## END OF SCRIPT: Ringtons-NextVisit.ps1
##=============================================
