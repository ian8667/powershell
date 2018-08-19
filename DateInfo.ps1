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
Last updated : 2018-08-19

For information regarding this subject (comment-based help),
execute the command:
PS> Get-Help about_comment_based_help

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
Param (
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
## Purpose: display a list weekending dates from
## the start of contract until the present.
##
## Returns: N/A
##=============================================
function Show-WeekendingDates()
{

BEGIN {
  # End of week date of the first week of the contract.
  # This date should be, for example, the Saturday of
  # the end of my first week on the contract.
  $hash = @{
      Year   = 2017;
      Month  = 09;
      Day    = 09;
  }
  $startdate = New-Object -TypeName PSObject -Property $hash;

  # Counts the number of weeks as we list them.
  [Byte]$weekCounter = 1;
  
  # Puts a blank line in the output every N lines depending
  # upon the value of this variable.
  [Byte]$blockSize = 5;
  Set-Variable -Name blockSize -Option ReadOnly;

  # This is the date from where our output starts from.
  $weekEnding = Get-Date -Year $startdate.Year -Month $startdate.Month -Day $startdate.Day;
  
  # The end date is determined to be the current date, ie whatever
  # today is. Our output will finish when it gets to this date.
  [System.DateTime]$endDate = Get-Date;
  Set-Variable -Name endDate -Option ReadOnly;

  Write-Host "Contract weekending information";
  Write-Host "";
}

PROCESS {

  do {

    Write-Host ("Week {0}, ending on {1}" -f $weekCounter, $weekEnding.ToString("yyyy-MM-dd"));

    if (($weekCounter % $blockSize) -eq 0) {
       Write-Host "";
    }
    $weekEnding = $weekEnding.AddDays(7.0);
    $weekCounter++;

  } until ($weekEnding -gt $endDate);

}

END {

  foreach ($num in 1..3) {Write-Host '';}
  Write-Host ('*' * 30);

  $weekCounter--;
  Write-Host ('Weeks listed: {0}' -f $weekCounter.ToString());
  Write-Host ("Start date used: {0}-{1}-{2}" -f `
              $startdate.Year.ToString(), `
              $startdate.Month.ToString("00"), `
              $startdate.Day.ToString("00"));

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

BEGIN {
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

PROCESS {
  if ($myMonth -in 1,2) {
     $myYear--;
     $myMonth += 12;
  }

  $i1 = [System.Math]::Truncate(365.25 * $myYear);
  $i2 = [System.Math]::Truncate(30.6001 * (++$myMonth));
  $jd = $i1 + $i2 + $myDay + 1720994.5 + $bb;

}

END {
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

BEGIN {
  Write-Verbose -Message "Executing function Show-DateInformation";

  foreach ($num in 1..2) {Write-Host ""}

  #[DateTime]$myDate = Get-Date -Format "dddd, dd MMMM yyyy HH:mm"
  $myDate = Get-Date;

  # Get the Julian Date for the current date.
  $jd = Get-JulianDate $myDate;

  $greg = New-Object -TypeName System.Globalization.GregorianCalendar;
  $time = [System.DateTime]::now;
  $rule = [System.Globalization.CalendarWeekRule]::FirstFullWeek;
  $dayofweek = [System.DayOfWeek]::Monday;
  $weekNum = $greg.GetWeekOfYear($time, $rule, $dayofweek);
}

PROCESS {
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

END {

  Write-Host ("Today is {0:dddd, dd MMMM yyyy HH:mm}" -f $myDate);
  Write-Host ("ISO 8601 date/time is {0:s}" -f $myDate);

  Out-String -InputObject $DayWeek -Width 50;

  Write-Verbose -Message "function Show-DateInformation done";

}

}
#endregion ********** end of function Show-DateInformation **********

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
## Returns: the week ending date
##=============================================
function Get-WeekendingDate()
{

BEGIN {
  $sat = [System.DayOfWeek]::Saturday;
  $tempDate = Get-Date;
  $tday = ($tempDate).DayOfWeek;
}

PROCESS {
  while ($tday -ne $sat) {
     $tempDate = $tempDate.AddDays(1.0);
     $tday = ($tempDate).DayOfWeek;
  }
}

END {
  return ($tempDate).ToString("yyyy-MM-dd");
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
  Write-Host "";
  Write-Host ('The next week ending coming up is Saturday, {0}' -f $WeekEnd);
}

Write-Verbose -Message "All done now!";
Write-Host "";
##=============================================
## END OF SCRIPT: DateInfo.ps1
##=============================================
