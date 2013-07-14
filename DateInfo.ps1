<#
.SYNOPSIS

Displays date related information

.DESCRIPTION

Displays date related information such as the current date/time,
ISO 8601 date/time, day number and week number.

.EXAMPLE

./DateInfo.ps1

No parameters are required or used.

.INPUTS

None. No .NET Framework types of objects are used as input.

.OUTPUTS

Sample output.

PS 22:59:20==> ./DateInfo.ps1


Today is Sunday, 30 June 2013 22:59
ISO 8601 date/time is 2013-06-30T22:59:36

DayNumber    WeekNumber   JulianDate   LeapYear
---------    ----------   ----------   --------
181          26           2456473.5    False

.NOTES

File Name    : DateInfo.ps1
Author       : Ian Molloy
Last updated : 2013-07-06

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
Param ()

#-------------------------------------------------
# Start of functions
#-------------------------------------------------

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

if ($myMonth -in 1,2) {
   $myYear--;
   $myMonth += 12;
}

$i1 = [System.Math]::Truncate(365.25 * $myYear);
$i2 = [System.Math]::Truncate(30.6001 * (++$myMonth));
$jd = $i1 + $i2 + $myDay + 1720994.5 + $bb;

Write-Verbose -Message "function Get-JulianDate done";
return $jd;
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

Write-Verbose -Message "Executing function Show-DateInformation";

foreach ($num in 1..3) {Write-Host ""}

#[DateTime]$myDate = Get-Date -Format "dddd, dd MMMM yyyy HH:mm"
$myDate = Get-Date;

Write-Host ("Today is {0:dddd, dd MMMM yyyy HH:mm}" -f $myDate);
Write-Host ("ISO 8601 date/time is {0:s}" -f $myDate);

<#
Add-Member -MemberType scriptmethod `
           -Name GetWeekOfYear `
           -Value {Get-Date -uformat %V} `
           -InputObject $myDate;
Write-Host "Week $($myDate.GetWeekOfYear())";
#>

# Get the Julian Date for the current date.
$jd = Get-JulianDate $myDate;

# See whether this is a leap year.
if ([System.DateTime]::IsLeapYear($myDate.Year)) {
  $leap = "True";
} else {
  $leap = "False";
}

# get current culture object
$Culture = [System.Globalization.CultureInfo]::CurrentCulture;

$hash = [ordered]@{
      DayNumber     = $myDate.DayOfYear.ToString("000")
      WeekNumber    = [String]$Culture.Calendar.GetWeekOfYear(
                                 $myDate,
                                 $Culture.DateTimeFormat.CalendarWeekRule,
                                 $Culture.DateTimeFormat.FirstDayOfWeek);
      JulianDate    = [String]$jd
      LeapYear      = $leap
}
$DayWeek = New-Object PSObject -Property $hash;
#Write-Output $DayWeek;
Out-String -InputObject $DayWeek -Width 50;

Write-Verbose -Message "function Show-DateInformation done";

}
#endregion ********** end of function Show-DateInformation **********

#-------------------------------------------------
# End of functions
#-------------------------------------------------
##=============================================
## SCRIPT BODY
## MAIN ROUTINE STARTS HERE
##=============================================
Write-Verbose -Message "Starting script $($MyInvocation.Mycommand)";

Show-DateInformation;

Write-Verbose -Message "All done now!";
##=============================================
## END OF SCRIPT: teatime.ps1
##=============================================
