<#
https://chrishayward.co.uk/2017/07/07/skype-for-business-automatically-set-rgs-holiday-sets-with-powershell-and-json/
https://docs.microsoft.com/en-us/powershell/module/ise/?view=powershell-5.1

Test program to obtain holiday dates throughout the year.

PS> $age=7
"{0:d3}" -f $age
007

Keywords: holiday public bank

Get-SmbShare | FT Name, Path, @{ Align="Center"; Expression={If ($_.Name –like “*$”) {“Yes”} else {“No”} }; Label=”Hidden” } –AutoSize
Source: https://blogs.technet.microsoft.com/josebda/2014/04/19/powershell-tips-for-building-objects-with-custom-properties-and-special-formatting/

PowerShell: Using the -F format Operator
https://social.technet.microsoft.com/wiki/contents/articles/7855.powershell-using-the-f-format-operator.aspx

PowerShell’s format operator
https://blogs.technet.microsoft.com/pstips/2014/10/18/powershells-format-operator/

Understanding PowerShell and Basic String Formatting
https://blogs.technet.microsoft.com/heyscriptingguy/2013/03/11/understanding-powershell-and-basic-string-formatting/

File Name    : Get-Holidays.ps1
Author       : Ian Molloy
Last updated : 2017-08-28

#>
[CmdletBinding()]
Param () #end param

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

BEGIN {
  $holDate = [System.DateTime]$HolidayDate;
}

PROCESS {}

END {
  return $holDate.DayOfWeek.ToString();
}

}
#endregion ***** end of function Get-DayOfWeek *****


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

BEGIN {
  $dateDifference = [System.DateTime]::Today - [System.DateTime]$HolidayDate;
  $indicator = '';
  $diffResult = [System.Math]::Sign($dateDifference.Days);
}

PROCESS {
   switch ($diffResult) {
      -1  {$indicator = 'Future'; break;} # the holiday is in the future
       0  {$indicator = 'Today'; break;}  # the holiday is today
       1  {$indicator = 'Past'; break;}   # the holiday is in the past
      default {$indicator = ('diffResult = {0}' -f $diffResult);}
   }
}

END {
  return $indicator;
}

}
#endregion ***** end of function Get-PastFuture *****


#region ***** function Start-MainRoutine *****
function Start-MainRoutine {
[CmdletBinding()]
[OutputType([System.Void])]
Param () #end param

BEGIN {
  $uri = "https://www.gov.uk/bank-holidays.json";
  $wantedYear = 2017; # year of interest
  $holidays = Invoke-RestMethod -Uri $uri |
              Select-Object -ExpandProperty 'england-and-wales';

  [System.Byte]$holidayCount = 0;
  $notes2 = '';
  $DayOfWeek = '';

  Write-Output ("`nEngland and Wales holiday dates for the year {0}`n" -f $wantedYear.ToString());

}

PROCESS {
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

END {}

}
#endregion ***** end of function Start-MainRoutine *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

Set-StrictMode -Version Latest;

Write-Output ("`nToday is {0:dddd, dd MMMM yyyy}" -f (Get-Date));

Invoke-Command -ScriptBlock {

   Write-Output '';
   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

Start-MainRoutine;

##=============================================
## END OF SCRIPT: Get-Holidays.ps1
##=============================================
