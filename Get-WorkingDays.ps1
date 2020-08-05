<#

Calculate remaining work days on the contract (last
working day of contract).

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
Last updated : 2020-08-04T15:49:18
Keywords     : last working day contract

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
$mask = 'dddd, dd MMMM yyyy';
$startDate = Get-Date;
#$endDate = Get-Date -Year 2020 -Month 03 -Day 24; #Last working day of contract
$endDate = Get-Date -Year 2020 -Month 08 -Day 24; #test date to use
$weekdays = @('Monday'
              'Tuesday'
              'Wednesday'
              'Thursday'
              'Friday');

Write-Output ('Start date used: {0}' -f $startDate.ToString($mask));
Write-Output ('End date used: {0}' -f $endDate.ToString($mask));
Write-Output '';

#Property 'Date' refers to the date component of the variables
if ($endDate.Date -le $startDate.Date) {
  throw "End date must be later than the start date";
}

#Find the interval in days between the start date and end date.
$interval = ($endDate - $startDate);
Set-Variable -Name 'startDate', 'endDate', 'weekdays', 'mask' -Option ReadOnly;

[UInt16]$counter = 0;

#Temporary working 'System.DateTime' variable.
$d = $startDate;
do {
  #date loop

  #Increment the counter if this is a weekday, otherwise do nothing.
  if ($d.DayOfWeek -in $weekdays) {
    $counter++;
    Write-Verbose -Message ('The date is now {0}' -f $d.ToString($mask));
  }

  $d = $d.AddDays(1);

} until ($d.CompareTo($endDate) -gt 0)

Write-Output '';
Write-Output ('Number of working days is {0}' -f ($counter));
Write-Output ('Total elapsed days is {0}' -f $interval.Days);
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Get-WorkingDays.ps1
##=============================================
