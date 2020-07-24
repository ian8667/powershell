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


Keywords: last day contract

#>

[CmdletBinding()]
Param() #end param

Write-Output 'Start of test';

$mask = 'dddd, dd MMMM yyyy';
$startDate = Get-Date;
$endDate = Get-Date -Year 2020 -Month 03 -Day 24; #Last working day of contract
#$endDate = Get-Date -Year 2020 -Month 03 -Day 16; #test date to use
$weekdays = @('Monday'
              'Tuesday'
              'Wednesday'
              'Thursday'
              'Friday');

#Find the interval in days between the start date and end date.
$interval = ($endDate - $startDate);
Set-Variable -Name 'startDate', 'endDate', 'weekdays', 'mask' -Option ReadOnly;

$counter = 0;

Write-Output ('Start date used: {0}' -f $startDate.ToString($mask));
Write-Output ('End date used: {0}' -f $endDate.ToString($mask));
Write-Output '';

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
Write-Output ('Working days is now {0}' -f ($counter));
Write-Output ('Total elapsed days is now {0} days' -f $interval.Days);
Write-Output 'End of test';

