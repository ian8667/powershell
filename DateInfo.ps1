<#
.SYNOPSIS

Displays date related information

.DESCRIPTION

Displays date related information such as the current date/time,
ISO 8601 date/time, day number and week number. Also shows
contract weekending dates if required.

ISO 8601 date (and time) format tackles date uncertainty by
setting out an internationally agreed way to represent dates
in the format of:

YYYY-MM-DD

For example, September 27, 2022 is represented as 2022-09-27.

Information shown:

DayNumber - the day of the year expressed as a value between 1
and 365 (366 in leap years). January 1 is day 1, January 2 is
day 2, February 2 is day 32 and so on until you get to the end
of the year.

WeekNumber - the week number within the year.

JulianDate - the elapsed time in days and fractions of a day
since January 1, 4713 BC Greenwich noon. The purpose of the
Julian date is to make it easy for computing difference between
one calendar date and another calendar date.

LeapYear - whether the current year is a leap year (True or False).

IsDST - whether this instance of DateTime is within the daylight
saving time range for the current time zone (True or False).

.PARAMETER WeekEndingDates

A 'switch' parameter which determines whether to display the end of
week date in the format of YYYY-MM-DD and a list of these week end
dates since the beginning of the contract up until the present date
(but not exceeding the present date). The end of the working week
is taken to be a Saturday on my current contract.

This was included for a recent contract I had where I needed the end
of week date for my time sheet. Using this script saves me having to
work out the date myself. Having a list of dates will help me if ever
I need to check any date submitted on my timesheets.

The end date of the first week of the contract (Saturday) is set in
function 'Show-WeekendingDates'.

Under normal circumstances, my preferred 'end of the week' day is a
Saturday but there will be occasions on some contracts where this
will be a Sunday. I can't explain why some contracts are like this.

.EXAMPLE

PS> .\DateInfo.ps1

Date related information
Today is Wednesday, 30 November 2022 16:04:42
Running script DateInfo.ps1 in directory C:\Family\powershell


Current ISO 8601 date/time is 2022-11-30T16:04:42

DayNumber WeekNumber JulianDate LeapYear IsDST
--------- ---------- ---------- -------- -----
334       48         2459913.5     False False

All done now!

.EXAMPLE

PS> ./DateInfo.ps1 -WeekEndingDates

Date related information
Today is Wednesday, 30 November 2022 18:32:50
Running script DateInfo.ps1 in directory C:\Family\powershell


Current ISO 8601 date/time is 2022-11-30T18:32:50

DayNumber WeekNumber JulianDate LeapYear IsDST
--------- ---------- ---------- -------- -----
334       48         2459913.5     False False

Contract weekending information

Week 1, ending on 2022-10-08
Week 2, ending on 2022-10-15
Week 3, ending on 2022-10-22
Week 4, ending on 2022-10-29
Week 5, ending on 2022-11-05

Week 6, ending on 2022-11-12
Week 7, ending on 2022-11-19
Week 8, ending on 2022-11-26



******************************
Weeks listed: 8
The first weekending date used: Saturday, 08 October 2022

The next week ending coming up after today is: Saturday, 03 December 2022
All done now!

.NOTES

File Name    : DateInfo.ps1
Author       : Ian Molloy
Last updated : 2022-11-30T14:21:23
Keywords     : contract end of week jd julian dst

.LINK

about_Comment_Based_Help:
http://technet.microsoft.com/en-us/library/dd819489.aspx

WTFM: Writing the Fabulous Manual:
http://technet.microsoft.com/en-us/magazine/ff458353.aspx

about_Functions_Advanced_Parameters:
http://technet.microsoft.com/en-us/library/hh847743.aspx

Cmdlet Parameter Sets:
http://msdn.microsoft.com/en-us/library/windows/desktop/dd878348(v=vs.85).aspx

Julian Date (JD) Calculator and Calendars
http://www.aavso.org/jd-calculator

Switch parameters:
System.Management.Automation.SwitchParameter
https://msdn.microsoft.com/en-us/library/system.management.automation.switchparameter(v=vs.85).aspx

Julian Date Converter, U.S. Naval Observatory, Astronomical
Applications Department
http://aa.usno.navy.mil/data/docs/JulianDate.php

Week numbers:
http://www.epochconverter.com/weeks/2016

Formatting Date Strings with PowerShell
https://devblogs.microsoft.com/scripting/formatting-date-strings-with-powershell/

ISO 8601 Date and Time format
https://www.iso.org/iso-8601-date-and-time-format.html

#>

[CmdletBinding()]
Param(
    [parameter(Position=0,
               Mandatory=$false,
               HelpMessage="Determines whether to display week ending information")]
    [Switch]$WeekEndingDates
) #end param

#-------------------------------------------------
# Start of functions
#-------------------------------------------------

#region ***** function Show-WeekendingDates *****
##=============================================
## Function: Show-WeekendingDates
## Last updated: 2021-12-11
## Author: Ian Molloy
## Arguments: N/A
##=============================================
## Purpose: display a list weekending dates (Saturday)
## from the start of contract until the present day.
##
## Returns: N/A
##=============================================
function Show-WeekendingDates {
[CmdletBinding()]
Param() #end param

Begin {

  # Counts the number of weeks as we list them.
  [Byte]$weekCounter = 0;

  # Puts a blank line in the output every N lines depending
  # upon the value of this variable. I feel that having a
  # blank line every now again makes the output easier to
  # read.
  [Byte]$blockSize = 5;

  # End date of the first week of the contract. This date
  # should be, for example, the Saturday of the end of the
  # first week on the contract. This date should be earlier
  # than the end date.
  $startDate = Get-Date -Year 2022 -Month 10 -Day 08;

  # The end date is determined to be the current date, whatever
  # today is (i.e. whenever the script is run). Our output will
  # finish when it gets past this date.
  $endDate = Get-Date;

  # Check the start date is earlier than the end date. Throw
  # a terminating error if this is not the case.
  $Result = (($startDate).CompareTo($endDate));
  if ($Result -gt 0) {
      throw "Start date [$($startDate.ToLongDateString())] must be earlier than end date [$($endDate.ToLongDateString())]";
  }

  # Check the start date is a Saturday. Throw a terminating
  # error if this is not the case.
  if (([System.DayOfWeek]::Saturday) -ne $startDate.DayOfWeek) {
    throw "Start date used [$($startDate.ToString('dd MMMM yyyy'))] must be a Saturday";
  }

  $iso8601Date = "yyyy-MM-dd";
  Set-Variable -Name 'blockSize', 'startDate', 'endDate', 'iso8601Date' -Option ReadOnly;

  Write-Output "Contract weekending information";
  Write-Output "";
}

Process {

  # loop in multiples of 7 days
  $tempDate = $startDate;
  do {
    $weekCounter++;

    Write-Output ("Week {0}, ending on {1}" -f $weekCounter, $tempDate.ToString($iso8601Date));

    # See whether we're due to insert a blank line in our output
    if (($weekCounter % $blockSize) -eq 0) {
       Write-Output "";
    }
    $tempDate = $tempDate.AddDays(7.0);

  } until ($tempDate -gt $endDate);

}

End {

  [System.Linq.Enumerable]::Repeat("", 2); #blanklines
  Write-Output ('*' * 30);

  Write-Output ('Weeks listed: {0}' -f $weekCounter.ToString());
  Write-Output ("The first weekending date used: {0}" -f $startDate.ToString("dddd, dd MMMM yyyy"));

}

} #end function Show-WeekendingDates
#endregion ***** end of function Show-WeekendingDates *****

#----------------------------------------------------------

#region ***** function Get-JulianDate *****
##=============================================
## Function: Get-JulianDate
## Created: 2013-06-30
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: calculates the Julian Date for the calendar
##          date supplied.
##
## Returns: the Julian Date calculated
##=============================================
## For Julian Date information and JD converters, see
## the following (in no specific order):
## Calendar date to Julian date.
## http://aa.usno.navy.mil/data/docs/JulianDate.php
##
## Gregorian Calendar to Julian Date Converter.
## http://www.ast.cam.ac.uk/~jcrass/jd-converter.php
##
## American Association of Variable Star Observers (AAVSO).
## http://www.aavso.org/jd-calculator
##
## JPL Solar System Dynamics Time Conversion Tool.
## http://ssd.jpl.nasa.gov/tc.cgi#top
##
## Harvard Mathematics Department Calendar Converter
## http://www.math.harvard.edu/computing/javascript/Calendar/
##
## http://www.usno.navy.mil/USNO/earth-orientation/eo-info/read-me
## http://aa.usno.navy.mil/data/
##
## JD Date/Time Converter
## Jet Propulsion Laboratory (JPL)
## https://ssd.jpl.nasa.gov/tools/jdc/#/cd
## https://ssd.jpl.nasa.gov/tools/jdc/#/jd
##
##=============================================
function Get-JulianDate {
[cmdletbinding()]
Param (
    [parameter(Mandatory=$true,
               Position=0)]
    [ValidateNotNullOrEmpty()]
    [DateTime]
    $CurrentDate
) #end param

Begin {
  Write-Verbose -Message "Executing function Get-JulianDate";

  [Double]$jd = 0.0;
  [DateTime]$myDate = $CurrentDate;
  [Int32]$aa = 0;
  [Int32]$bb = 0;
  [Int32]$myYear = $myDate.Year;
  [Int32]$myMonth = $myDate.Month;
  [Int32]$myDay = $myDate.Day;
  [Int32]$i1 = 0;
  [Int32]$i2 = 0;

  $aa = [System.Math]::Truncate($myDate.Year / 100);
  $bb = 2 - $aa + [System.Math]::Truncate($aa / 4);

}

Process {
  if ($myMonth -in 1,2) {
     $myYear--;
     $myMonth += 12;
  }

  $i1 = [System.Math]::Truncate(365.25 * $myYear);
  $i2 = [System.Math]::Truncate(30.6001 * (++$myMonth));
  $jd = $i1 + $i2 + $myDay + 1720994.5 + $bb;

}

End {
  Write-Verbose -Message "function Get-JulianDate done";
  return $jd;

}
}
#endregion ***** end of function Get-JulianDate *****

#----------------------------------------------------------

#region ***** function Show-DateInformation *****
##=============================================
## Function: Show-DateInformation
## Created: 2013-06-30
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: displays date related information and does
##          the main work for the program.
##
## Returns: N/A
##=============================================
function Show-DateInformation {
[CmdletBinding()]
Param() #end param

Begin {
  Write-Verbose -Message "Executing function Show-DateInformation";

  [System.Linq.Enumerable]::Repeat("", 2); #blanklines

  $myDate = Get-Date;

  # Get the Julian Date for the current date.
  $jd = Get-JulianDate -CurrentDate $myDate;

  $greg = [System.Globalization.GregorianCalendar]::new();
  $rule = [System.Globalization.CalendarWeekRule]::FirstFullWeek;
  $dayofweek = [System.DayOfWeek]::Monday;
  $weekNum = $greg.GetWeekOfYear($myDate, $rule, $dayofweek);
}

Process {

  # get current culture object
  $Culture = [System.Globalization.CultureInfo]::CurrentCulture;

  $hash = [ordered]@{
        DayNumber   = $myDate.DayOfYear.ToString("000");
        WeekNumber  = $weekNum.ToString();
        JulianDate  = [String]$jd;
        LeapYear    = [System.DateTime]::IsLeapYear($myDate.Year);
        IsDST       = $myDate.IsDaylightSavingTime();
  }
  $DayWeek = New-Object -TypeName PSObject -Property $hash;

}

End {

  Write-Output ("Current ISO 8601 date/time is {0:s}" -f $myDate);

  Write-Output $DayWeek | Format-Table *;
  Write-Verbose -Message "function Show-DateInformation done";

}

}
#endregion ***** end of function Show-DateInformation *****

#----------------------------------------------------------

#region ***** function Get-WeekendingDate *****
##=============================================
## Function: Get-WeekendingDate
## Last updated: 2021-12-11
## Author: Ian Molloy
## Arguments: N/A
##=============================================
## Purpose: calculates the next week ending date which
## is the Saturday following the day this program is
## run.
##
## 'Today' is defined as the day this program is run.
##
## Returns: the week ending date
##=============================================
function Get-WeekendingDate {
[CmdletBinding()]
Param() #end param

Begin {
  $eow = [System.DayOfWeek]::Saturday; #end of week
  Set-Variable -Name 'eow' -Option ReadOnly;

  # Get todays date
  $tempDate = Get-Date;
  # see what day of the week variable $tempDate is
  $weekday = $tempDate.DayOfWeek;
}

Process {
  # keep looping until we find the next 'end of week' day
  # from today.
  do {
    $tempDate = $tempDate.AddDays(1.0);

    $weekday = $tempDate.DayOfWeek;
  } while ($weekday -ne $eow)

}

End {
  return $tempDate;
}

} #end function Get-WeekendingDate
#endregion ***** end of function Get-WeekendingDate *****

#-------------------------------------------------
# End of functions
#-------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Date related information';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

Show-DateInformation;

if ($WeekEndingDates.IsPresent) {
  # A Boolean: true if the parameter was specified on the
  # command line; otherwise, false.
  Show-WeekendingDates;
  $WeekEnd = Get-WeekendingDate;
  $msg = "The next week ending coming up after today is: {0}";
  Write-Output '';
  Write-Output ($msg -f $WeekEnd.ToString("dddd, dd MMMM yyyy"));
}

Write-Output "All done now!";
Write-Output "";
##=============================================
## END OF SCRIPT: DateInfo.ps1
##=============================================
