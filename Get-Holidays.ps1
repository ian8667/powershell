<#
.SYNOPSIS

Displays a list of bank holidays for the current year

.DESCRIPTION

Displays a list of Bank Holidays in England and Wales as listed
on a web site maintained by the government. The site also includes
a list of holidays for Scotland and Northern Ireland.

See the COMMENT-BASED help keyword '.EXAMPLE' for details of the
columns used
or
"get-help C:\Family\powershell\Get-Holidays.ps1 -examples"

.EXAMPLE

./Get-Holidays.ps1

Sample output (for the year 2017):


Today is Tuesday, 29 August 2017

Running script Get-Holidays.ps1 in directory C:\Family\powershell

England and Wales holiday dates for the year 2017

New Year's Day            2017-01-02  Substitute day    Past    Monday
Good Friday               2017-04-14                    Past    Friday
Easter Monday             2017-04-17                    Past    Monday
Early May bank holiday    2017-05-01                    Past    Monday
Spring bank holiday       2017-05-29                    Past    Monday
Summer bank holiday       2017-08-28                    Past    Monday
Christmas Day             2017-12-25                    Future  Monday
Boxing Day                2017-12-26                    Future  Tuesday

Holidays listed: 8


Explanation of the columns used

Column 1: The name of the holiday, ie Christmas Day.
Column 2: The date of the holiday in the format of YYYY-MM-DD.
Column 3: Any notes regarding the holiday. In the above example,
          New Year's Day holiday on the date 2017-01-02 (not
          2017-01-01 as expected) is a 'Substitute day' because
          January 1st is on a Sunday so therefore Monday becomes
          the holiday.
Column 4: Whether the holiday is in the 'Past' or the 'Future'. If
          the script were to be run on Christmas Day, apart from
          getting some nice presents this column will read 'Today'
          indicating the holiday in question is the day of running
          the script.
Column 4: Day of the week the holiday falls on.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Get-Holidays.ps1
Author       : Ian Molloy
Last updated : 2020-08-03T22:54:14

.LINK

UK bank holidays
https://www.gov.uk/bank-holidays

UK bank holidays (JSON format)
https://www.gov.uk/bank-holidays.json

The UK & Great Britain ? What?s the Difference?
http://www.historic-uk.com/HistoryUK/HistoryofBritain/The-UK-Great-Britain-Whats-the-Difference/

Strongly Encouraged Development Guidelines
https://msdn.microsoft.com/en-us/library/dd878270(v=vs.85).aspx

DynamicParam
The syntax to create a dynamic parameter is:
DynamicParam {<statement-list>}
http://www.powershellmagazine.com/2014/05/29/dynamic-parameters-in-powershell/

Powershell is dynamic parameters
http://www.adamtheautomator.com/psbloggingweek-dynamic-parameters-and-parameter-validation/

Windows PowerShell: Comment your way to help
https://technet.microsoft.com/en-us/library/hh500719.aspx

About Comment Based Help
https://goo.gl/uGWE36

Troubleshooting Comment-Based Help
https://www.sapien.com/blog/2015/02/18/troubleshooting-comment-based-help/

#>
[CmdletBinding()]
Param () #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function Get-DayOfWeek *****
function Get-DayOfWeek {
[CmdletBinding()]
[OutputType([System.String])]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $HolidayDate
      ) #end param

Begin {
  $holDate = [System.DateTime]$HolidayDate;
}

Process {}

End {
  return $holDate.DayOfWeek.ToString();
}

}
#endregion ***** end of function Get-DayOfWeek *****

#----------------------------------------------------------

#region ***** function Get-PastFuture *****
function Get-PastFuture {
[CmdletBinding()]
[OutputType([System.String])]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $HolidayDate
      ) #end param

Begin {
  $dateDifference = ([System.DateTime]::Today - [System.DateTime]$HolidayDate);
  $indicator = '';
  $diffResult = [System.Math]::Sign($dateDifference.Days);
}

Process {
   switch ($diffResult) {
      -1  {$indicator = 'Future'; break;} # the holiday is in the future
       0  {$indicator = 'Today'; break;}  # the holiday is today
       1  {$indicator = 'Past'; break;}   # the holiday is in the past
      default {$indicator = ('diffResult = {0}' -f $diffResult);}
   }
}

End {
  return $indicator;
}

}
#endregion ***** end of function Get-PastFuture *****

#----------------------------------------------------------

#region ***** function Start-MainRoutine *****
function Start-MainRoutine {
[CmdletBinding()]
[OutputType([System.Void])]
Param () #end param

Begin {
  $uri = "https://www.gov.uk/bank-holidays.json";
  $wantedYear = (Get-Date).Year; # year of interest
  $holidays = Invoke-RestMethod -Uri $uri |
              Select-Object -ExpandProperty 'england-and-wales';

  [System.Byte]$holidayCount = 0;
  $notes2 = '';
  $DayOfWeek = '';

  Write-Output ("`nEngland and Wales holiday dates for the year {0}`n" -f $wantedYear.ToString());

}

Process {
  $holidays.events |
    Where-Object {$_.date -Match $wantedYear.ToString()} |
    ForEach-Object `
       -Process {
            $event = $_;
            $holidayCount++;
            $notes2 = Get-PastFuture $event.date;
            $DayOfWeek = Get-DayOfWeek $event.date;

            Write-Output ('{0,-26}{1,-12}{2,-18}{3,-8}{4}' -f
                          $event.title, $event.date, $event.notes, $notes2, $DayOfWeek);
       } `
       -End {
          Write-Output ("`nHolidays listed: {0}`n" -f $holidayCount.ToString());
       }

  }

End {}

}
#endregion ***** end of function Start-MainRoutine *****

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
   Write-Output 'UK holidays';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

Start-MainRoutine;

##=============================================
## END OF SCRIPT: Get-Holidays.ps1
##=============================================
