<#

.SYNOPSIS

Show when Ringtons tea van is next due

.DESCRIPTION

Increments in steps of 14 days (two weeks) the date from a known
start date to determine when the Ringtons tea van is next due

.EXAMPLE

./Ringtons-NextVisit.ps1

No parameters required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Ringtons-NextVisit.ps1
Author       : Ian Molloy
Last updated : 2021-10-29T16:59:13

Ringtons Ltd, Algernon Road, Newcastle upon Tyne, NE6 2YN
Tel: 0800 052 2440
Email: tea@ringtons.co.uk

.LINK

https://www.ringtons.co.uk/
#>

[CmdletBinding()]
Param () #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {
<#
$MyInvocation
TypeName: System.Management.Automation.InvocationInfo
This automatic variable contains information about the current
command, such as the name, parameters, parameter values, and
information about how the command was started, called, or
invoked, such as the name of the script that called the current
command.

$MyInvocation is populated differently depending upon whether
the script was run from the command line or submitted as a
background job. This means that $MyInvocation may not be able
to return the path and file name of the script concerned as
intended.
#>
   Write-Output '';
   Write-Output "Date of Ringtons tea van next visit";
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   if ($MyInvocation.OffsetInLine -ne 0) {
       #I think the script was run from the command line
       $script = $MyInvocation.MyCommand.Name;
       $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
       Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);
   }

} #end of Invoke-Command -ScriptBlock

$dateMask = 'dddd, dd MMMM yyyy';
Set-Variable -Name 'dateMask' -Option ReadOnly;
$startDate = Get-Date -Year 2021 -Month 06 -Day 09;
$endDate = Get-Date;
$DaysToAdd = 14; #ie, two weeks
Set-Variable -Name 'startDate', 'endDate', 'DaysToAdd' -Option ReadOnly;

Write-Verbose -Message ("Start date used: {0}" -f $startDate.ToString($dateMask));
# loop in multiples of 14 days from the start date. This will
# enable us to determine the next visit date. Potentially,
# depending on when the next Ringtons visit is due, variable
# '$tempDate' may well be several days into the future when
# the loop terminates and is the date when Ringtons is next
# due to visit.
$tempDate = $startDate;
do {
    $tempDate = $tempDate.AddDays($DaysToAdd);
} until ($tempDate.Date -ge $endDate.Date);

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output ('Ringtons next visit is on {0}' -f $tempDate.ToString($dateMask));
$Difference = New-TimeSpan -Start $endDate.Date -End $tempDate.Date;
if ($Difference.Days -eq 0) {
    Write-Warning -Message 'Which is today!';
} else {
    Write-Output ('In {0} days time' -f $Difference.Days);
}

##=============================================
## END OF SCRIPT: Ringtons-NextVisit.ps1
##=============================================
