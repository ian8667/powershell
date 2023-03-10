<#

Calculate the number of working days (excluding holidays and
weekends) between two dates

System.DateTime - CompareTo(DateTime)
Example: $tempDate.CompareTo($endDate);
The 'CompareTo' method compares the value of $tempDate to a
specified DateTime value ($endDate) and returns an integer
that indicates whether $tempDate is earlier than, the same
as, or later than the specified DateTime ($endDate) value.

Less than zero - $tempDate is earlier than $endDate.
Zero - $tempDate is the same as $endDate.
Greater than zero - $tempDate is later than $endDate, or value is null.

File Name    : Get-WorkingDays.ps1
Author       : Ian Molloy
Last updated : 2023-02-16T17:42:44
Keywords     : count working days

TimeOnly and DateOnly Struct (Namespace: System).

DateTime.Now Property
An object whose value is the current local date and time.
DateTime.Today Property
An object that is set to today's date, with the time component set to 00:00:00.

To get current date only:
$dateNow = [System.DateOnly]::FromDateTime([System.DateTime]::Today);
or
$dateNow = Get-Date -Format 'D'; (ie, gives: 02 December 2022)

To get current time only:
$timeNow = [System.TimeOnly]::FromDateTime([System.DateTime]::Now);
or
$timeNow = Get-Date -Format 'T'; (ie, gives: 12:54:03)


[System.Enum]::GetNames( [System.DayOfWeek] )

PowerShell: Creating Custom Objects
https://social.technet.microsoft.com/wiki/contents/articles/7804.powershell-creating-custom-objects.aspx

Enumeration format strings
https://learn.microsoft.com/en-us/dotnet/standard/base-types/enumeration-format-strings?source=recommendations

#>

<#
new work:
o Can I convert this program to use System.DateOnly structures
instead of System.DateTime?

o insert advanced comments in file header

o structure the program a bit (?)

o Shall I put my holidays and weekend structures in a delegate?
$fred = [System.DateOnly]::Parse('2022-02-10') ;works

example code:
# Populate the holiday structure like this
[DateOnly[]]$hh = @(
  #Date format to use for holidays; YYYY-MM-DD
  [System.DateOnly]::Parse('2022-02-10');
  [System.DateOnly]::Parse('2022-02-12');
  [System.DateOnly]::Parse('2022-02-14');
)
# Test like this
$fred = [System.DateOnly]::Parse('2022-02-21');
$hh.Contains($fred); # returns true or false

o shall I use System.Collections.Generic.List<T> Class ?
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

   Write-Output '';
   Write-Output 'Number of working days between two dates';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
$dateMask = 'dddd, dd MMMM yyyy';
Set-Variable -Name 'dateMask' -Option ReadOnly;

#Start and end dates used by the program
$StartEndDates = [PSCustomObject]@{
   # Change accordingly
   PSTypeName = 'StartEnd';
   StartDate  = New-Object -TypeName 'System.DateOnly' -ArgumentList 2023,01,17 #year,month,day
   EndDate    = [System.DateOnly]::FromDateTime([System.DateTime]::Today);
}
Set-Variable -Name 'StartEndDates' -Option ReadOnly;

[String[]]$Weekdays = @(
            'Monday'
            'Tuesday'
            'Wednesday'
            'Thursday'
            'Friday');
[String[]]$Weekend = @(
           'Saturday'
           'Sunday');
Set-Variable -Name 'Weekdays','Weekend' -Option ReadOnly;

#Example of holidays or other days to ignore from our
#count of working days
[DateTime[]]$SampleHolidays = @(
  #Example date format to use for holidays; YYYY-MM-DD
  (Get-Date -Date '2020-06-08')
  (Get-Date -Date '2020-06-11')
)
#A list of holidays and any other days you wish to exclude
#from the count of working days. Dates in this data structure
#will be ignored and not counted. If there are no holidays or
#other days to be aware of, leave this variable as an empty
#array. i.e., $holidays = @()
[DateTime[]]$Holidays = @(
  #Date format to use for holidays; YYYY-MM-DD
  (Get-Date -Date '2022-02-10')
)
Set-Variable -Name 'Holidays' -Option ReadOnly;

Write-Output ('Start date used: {0}' -f $($StartEndDates.StartDate).ToString($dateMask));
Write-Output ('End date used: {0}' -f $($StartEndDates.EndDate).ToString($dateMask));
Write-Output '';

if ($($StartEndDates.EndDate).Date -le $($StartEndDates.StartDate).Date) {
  throw "End date must be later than the start date";
}

#Find the interval in days between the start date and end date.
$DateInterval = New-TimeSpan -Start $StartEndDates.StartDate -End $StartEndDates.EndDate;
Set-Variable -Name 'DateInterval' -Option ReadOnly;

#Count the number of working days
[UInt16]$WorkdayCounter = 0;

$tempDate = $StartEndDates.StartDate;
[String]$msg = '';
do {
  #date loop
  if ( ($Weekend.Contains($tempDate.DayOfWeek.ToString())) -or
       ($Holidays.Contains($tempDate.Date)) ) {

    #This day will be ignored as it is either a weekend or a holiday
    $msg = [System.String]::Format('{0} date ignored, - holiday or weekend', $tempDate.ToString($dateMask));
  } else {

    #This is a valid working day to count
    $msg = [System.String]::Format('The date is now {0}', $tempDate.ToString($dateMask));
    $WorkdayCounter++;
  }
  Write-Verbose -Message $msg;

  $tempDate = $tempDate.AddDays(1);

} until ($tempDate.CompareTo($StartEndDates.EndDate) -gt 0)

Write-Output '';
Write-Output ('Number of working days is {0}' -f ($WorkdayCounter));
Write-Output ('Total elapsed days (including weekends/holidays) is {0}' -f ($DateInterval.Days + 1));
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Get-WorkingDays.ps1
##=============================================
