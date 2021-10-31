<#
Camborne Trevithick Day
The day, always held on the last Saturday of April, celebrates the engineering and mining history of the Camborne area, and is dedicated to Richard Trevithick, pioneer of high pressure steam power & inventor of Road and Railway Locomotives.

#>

#----------------------------------------------------------
# Start of delegates
#----------------------------------------------------------

[Func[Int32,DateTime]]$Get_TrevithickDate = {
param($x)

$saturday = [System.DayOfWeek]::Saturday;
$year = $x;
$april = 4;
$TempDate = Get-Date -Year $year -Month  $april -Day 30;
Set-Variable -name 'saturday', 'year','april' -Option ReadOnly;

while ($TempDate.DayOfWeek -ne $saturday) {
   # Go backwards from the end of the month until
   # we get to a Saturday.
   $TempDate = $TempDate.AddDays(-1);
}

$TempDate;
} #end Func

#----------------------------------------------------------

[Action[Int32,DateTime]]$Show_TrevithickDate = {
param($x, $y)
$dateMask = 'dddd, dd MMMM';
$InformationPreference = 'Continue';
Write-Output 'this is a write output';
#Write-Information -MessageData "this is information";
Write-Host ('Trevithick day for {0} is {1}' -f $x,$y.ToString($dateMask));
[console]::WriteLine('hello world console');
}

#----------------------------------------------------------
# End of delegates
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Write-Output 'start of test';

$dateMask = 'dddd, dd MMMM';
$yy = (Get-Date).year;
foreach ($year in $yy..($yy+4)) {
  $result = $Get_TrevithickDate.Invoke($year);
  #$Show_TrevithickDate.Invoke($year,$result);
  Write-Output ('Trevithick day for {0} is {1}' -f $year,$result.ToString($dateMask));
}

#Write-Output ('(1)Trevithick day for {0} is {1}' -f $year,$result.ToString($dateMask));

Write-Output 'end of test';

