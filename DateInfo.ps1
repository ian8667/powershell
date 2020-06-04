<#
.SYNOPSIS

Displays date related information

.DESCRIPTION

Displays date related information such as the current date/time,
ISO 8601 date/time, day number and week number.

.PARAMETER WeekEnding

A 'switch' parameter which determines whether to display the end of
week date in the format of YYYY-MM-DD and a list of these week end
dates since the beginning of the contract up until the present date
(but not exceeding the present date). The end of the working week
is taken to be a Saturday on my current contract.

This was included for a recent contract I had where I needed the end
of week date for my time sheet. Using this script saves me having to
work out the date myself. Having a list of dates will help me if ever
I need to check any date submitted on my timesheets.

.EXAMPLE

PS> ./DateInfo.ps1


Today is Sunday, 13 November 2016 21:42
ISO 8601 date/time is 2016-11-13T21:42:11

DayNumber    WeekNumber   JulianDate   LeapYear
---------    ----------   ----------   --------
318          46           2457705.5    True


.EXAMPLE

PS> .\DateInfo.ps1 -WeekEnding


Today is Monday, 02 January 2017 16:26
ISO 8601 date/time is 2017-01-02T16:26:45

DayNumber    WeekNumber   JulianDate   LeapYear
---------    ----------   ----------   --------
002          1            2457755.5    False

Weekending information

Week 1, ending on 2016-10-29
Week 2, ending on 2016-11-05
Week 3, ending on 2016-11-12
Week 4, ending on 2016-11-19

Week 5, ending on 2016-11-26
Week 6, ending on 2016-12-03
Week 7, ending on 2016-12-10
Week 8, ending on 2016-12-17

Week 9, ending on 2016-12-24
Week 10, ending on 2016-12-31

The next week ending coming up is Saturday, 2017-01-07

.NOTES

File Name    : DateInfo.ps1
Author       : Ian Molloy
Last updated : 2020-06-04T21:27:42

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

#>

[CmdletBinding()]
Param(
    [parameter(Position=0,
               Mandatory=$false,
               HelpMessage="Determines whether to display week ending information")]
    [Switch]$WeekEnding
) #end param

#-------------------------------------------------
# Start of functions
#-------------------------------------------------

#region ***** function Show-WeekendingDates *****
##=============================================
## Function: Show-WeekendingDates
## Created: 2017-01-01
## Author: Ian Molloy
## Arguments: N/A
##=============================================
## Purpose: display a list weekending dates (Saturday)
## from the start of contract until the present.
##
## Returns: N/A
##=============================================
function Show-WeekendingDates
{

Begin {

  # Counts the number of weeks as we list them.
  [Byte]$weekCounter = 1;

  # Puts a blank line in the output every N lines depending
  # upon the value of this variable.
  [Byte]$blockSize = 5;

  # End date of the first week of the contract. This
  # date should be, for example, the Saturday of the
  # end of the first week on the contract. This date
  # should be earlier than the end date.
  $startDate = Get-Date -Year 2019 -Month 11 -Day 30;

  # The end date is determined to be the current date, whatever
  # today is. Our output will finish when it gets to this date.
  $endDate = Get-Date;

  # Check the start date is earlier than the end date. Throw
  # a terminating error if this is not the case.
  $Result = (($startDate.Date).CompareTo($endDate.Date));
  if ($Result -ge 0) {
      throw "Start date $($startDate) must be earlier than end date $($endDate)";
  }

  # Check the start date is a Saturday. Throw a terminating
  # error if this is not the case.
  if (([System.DayOfWeek]::Saturday) -ne $startDate.DayOfWeek) {
    throw "Start date $($startDate) must be a Saturday";
  }

  Set-Variable -Name 'blockSize', 'startDate', 'endDate' -Option ReadOnly;

  Write-Output "Contract weekending information";
  Write-Output "";
}

Process {

  # loop in multiples of 7 days
  $tempDate = $startDate;
  do {

    Write-Output ("Week {0}, ending on {1}" -f $weekCounter, $tempDate.ToString("yyyy-MM-dd"));

    # see whether we're due to insert a blank line in our output
    if (($weekCounter % $blockSize) -eq 0) {
       Write-Output "";
    }
    $tempDate = $tempDate.AddDays(7.0);
    $weekCounter++;

  } until ($tempDate -gt $endDate);

}

End {

  foreach ($num in 1..3) {Write-Output '';}
  Write-Output ('*' * 30);

  $weekCounter--;
  Write-Output ('Weeks listed: {0}' -f $weekCounter.ToString());
  Write-Output ("Start date used: {0}" -f $startDate.ToString("dddd, dd MMMM yyyy"));

}

} #end function Show-WeekendingDates
#endregion ***** end of function Show-WeekendingDates *****

#region ********** function Get-JulianDate **********
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
#endregion ********** end of function Get-JulianDate **********

#region ********** function Show-DateInformation **********
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
function Show-DateInformation() {

Begin {
  Write-Verbose -Message "Executing function Show-DateInformation";

  foreach ($num in 1..2) {Write-Output ""}

  $myDate = Get-Date;

  # Get the Julian Date for the current date.
  $jd = Get-JulianDate $myDate;

  $greg = New-Object -TypeName System.Globalization.GregorianCalendar;
  $time = [System.DateTime]::now;
  $rule = [System.Globalization.CalendarWeekRule]::FirstFullWeek;
  $dayofweek = [System.DayOfWeek]::Monday;
  $weekNum = $greg.GetWeekOfYear($time, $rule, $dayofweek);
}

Process {
  # See whether this is a leap year.
  if ([System.DateTime]::IsLeapYear($myDate.Year)) {
    $leap = "True";
  } else {
    $leap = "False";
  }

  # get current culture object
  $Culture = [System.Globalization.CultureInfo]::CurrentCulture;

  $hash = [ordered]@{
        DayNumber   = $myDate.DayOfYear.ToString("000");
        WeekNumber  = $weekNum.ToString();
        JulianDate  = [String]$jd;
        LeapYear    = $leap;
  }
  $DayWeek = New-Object -TypeName PSObject -Property $hash;

}

End {

  Write-Output ("Today is {0:dddd, dd MMMM yyyy HH:mm}" -f $myDate);
  Write-Output ("ISO 8601 date/time is {0:s}" -f $myDate);

  Out-String -InputObject $DayWeek -Width 50;

  Write-Verbose -Message "function Show-DateInformation done";

}

}
#endregion ***** end of function Show-DateInformation *****

#region ***** function Get-WeekendingDate *****
##=============================================
## Function: Get-WeekendingDate
## Created: 2016-11-13
## Author: Ian Molloy
## Arguments: N/A
##=============================================
## Purpose: calculates the week ending date which is
## the Saturday following the day this program is run.
##
## 'Today' is defined as the day this program is run.
##
## Returns: the week ending date
##=============================================
function Get-WeekendingDate
{

Begin {
  $sat = [System.DayOfWeek]::Saturday;
  Set-Variable -Name 'sat' -Option ReadOnly;
  # ie, todays date
  $tempDate = Get-Date;
  # see what day of the week today is
  $weekday = ($tempDate).DayOfWeek;
}

Process {
  # keep looping until we find the next Saturday from today
  while ($weekday -ne $sat) {
     $tempDate = $tempDate.AddDays(1.0);

     $weekday = ($tempDate).DayOfWeek;
  }
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

Write-Verbose -Message "Starting script $($MyInvocation.Mycommand)";

Show-DateInformation;

if ($WeekEnding.IsPresent) {
  # A Boolean: true if the parameter was specified on the
  # command line; otherwise, false.
  Show-WeekendingDates;
  $WeekEnd = Get-WeekendingDate;
  $msg = "The next week ending coming up after today is: {0}";
  Write-Output '';
  Write-Output ($msg -f $WeekEnd.ToString("dddd dd MMMM yyyy"));
}

Write-Verbose -Message "All done now!";
Write-Output "";
##=============================================
## END OF SCRIPT: DateInfo.ps1
##=============================================
