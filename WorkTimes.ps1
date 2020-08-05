<#
.SYNOPSIS

Calculates work related time information

.DESCRIPTION

Calculates and displays work related time information from a number
of different perspectives according to the way used.

Lists times derived from:
    o start and end times as entered, and elapsed time
    o elapased time worked added to the start time
    o start and end time, and elapsed time if you were go home
      at the time of running the script. i.e. go home right now.
    o shows the end time added to the start time for a standard
      working day.

.PARAMETER StartTime

The time of starting working entered in the format of HH:MM. i.e.
09:00.

This is a mandatory parameter.

.PARAMETER EndTime

End of the working day time. i.e. when you finished work. The time
is entered in the format of HH:MM. i.e. 16:30.

This is an optional parameter.

.PARAMETER AddTime

An elapsed time to add to the start time to derive the start/end times
and elapsed time worked. The format used is HH:MM. i.e. 05:40.

This is an optional parameter.

.PARAMETER GoHomeNow

A switch parameter signalling that the current time (time of running
the script) will be taken as the end time. In effect, this time will
be used in a similar manner to the parameter 'EndTime'.

This is an optional parameter.

.PARAMETER HomeTime

A switch parameter signalling that the standard working day time
will be added to the start time to produce a start and end time.
i.e. this will show 'normal' working day times with no extra time
worked.

This is an optional parameter.

.EXAMPLE

./WorkTimes.ps1 -StartTime 09:00 -EndTime 16:40

Entering the start and end time will show these times as well
as the elapsed time worked.

.EXAMPLE

./WorkTimes.ps1 -StartTime 09:10 -AddTime 05:20

A time worked of 5 hours 20 minutes is added to the start time
giving the start and end times as well as the elapsed time worked.

.EXAMPLE

./WorkTimes.ps1 -StartTime 09:30 -GoHomeNow

Using the parameter 'GoHomeNow' will cause the program to use the
time of running as the end time. The start and end times, as well
as the elapsed time worked will be displayed.

.EXAMPLE

./WorkTimes.ps1 -StartTime 09:15 -HomeTime

Using the parameter 'HomeTime' will cause the program to add The
standard work day time to help derive start and end times as
well as confirming the elapsed time. In this instance, the elapsed
time will be the same as the standard working day time. At the of
writing, the standard working day is 7 hours 15 minutes.

.INPUTS

None. No .NET Framework types of objects are used as input.

.OUTPUTS

None. No .NET Framework types of objects are output from this script.

.NOTES

Times entered should be in the format of HH:MM, i.e. 09:00. Leading
and trailing zeros are required to prevent an error message such as,
for example:

C:\Family\powershell\WorkTimes.ps1 : Cannot validate argument on parameter 'AddTime'. The argument "5:10" does not
match the "\d{2}:\d{2}" pattern. Supply an argument that matches "\d{2}:\d{2}" and try the command again.
At line:1 char:43
+ .\WorkTimes.ps1 -StartTime 09:10 -AddTime 5:10
+                                           ~~~~
    + CategoryInfo          : InvalidData: (:) [WorkTimes.ps1], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,WorkTimes.ps1


File Name    : WorkTimes.ps1
Author       : Ian Molloy
Last updated : 2020-08-05T13:37:53

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
Param (
    [parameter(Mandatory=$true,
               HelpMessage="Enter the start time (HH:MM)",
               Position=0)]
    [ValidatePattern("\d{2}:\d{2}")]
    [ValidateNotNullOrEmpty()]
    [String]
    $StartTime,

    [parameter(Mandatory=$false,
               HelpMessage="Enter the end time (HH:MM)",
               Position=1,
               ParameterSetName="Set1")]
    [ValidatePattern("\d{2}:\d{2}")]
    [ValidateNotNullOrEmpty()]
    [String]
    $EndTime,

    [parameter(Mandatory=$false,
               HelpMessage="Enter the elapsed time (HH:MM)",
               ParameterSetName="Set2")]
    [ValidatePattern("\d{2}:\d{2}")]
    [ValidateNotNullOrEmpty()]
    [String]
    $AddTime,

    [parameter(Mandatory=$false,
               ParameterSetName="Set3")]
    [switch]
    $GoHomeNow,

    [parameter(Mandatory=$false,
               ParameterSetName="Set4")]
    [switch]
    $HomeTime
) #end param

#-------------------------------------------------
# Start of functions
#-------------------------------------------------

#region ***** function Show-TimeDifference *****
##=============================================
## Function: Show-TimeDifference
## Created: 2013-06-19
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: displays the time difference between the start
##          time and the end time given and thus the hours
##          worked.
##
## Returns: N/A
##=============================================
## See also: DateTime Structure
## http://msdn.microsoft.com/en-us/library/system.datetime.aspx
##=============================================
## Note:
## This function relies upon the parameters $StartTime, $EndTime.
##=============================================
function Show-TimeDifference {
[CmdletBinding()]
#[OutputType([System.Collections.Hashtable])]
Param() #end param

  Write-Verbose -Message "This is function Show-TimeDifference";

  New-Variable -Name timeFormat -Value "HH:mm" -Option Constant -Scope Local;
  $culture = New-Object -TypeName System.Globalization.CultureInfo("en-GB");

  $hash = @{
     StartTime=[DateTime]::ParseExact($StartTime, $timeFormat, $culture)
     EndTime=[DateTime]::ParseExact($EndTime, $timeFormat, $culture);
  }
  $userTimes = New-Object PSObject -Property $hash

  # Check that the end date is later than the start date.
  $checkdate = $userTimes.StartTime.CompareTo($userTimes.EndTime);
  if ($checkdate -ge 0) {
     $message = "End date ({0}) must be greater than start date ({1})" `
                 -f $userTimes.StartTime, $userTimes.EndTime;
     $exception = New-Object -TypeName InvalidOperationException $message;
     $errorID = 'InvalidStartEndDates';
     $errorCategory = [Management.Automation.ErrorCategory]::InvalidArgument;
     $target = "start/end dates";
     $errorRecord = New-Object -TypeName Management.Automation.ErrorRecord `
                     $exception,
                     $errorID,
                     $errorCategory,
                     $target;
     #$PSCmdlet.ThrowTerminatingError($errorRecord);
     $recAction="Ensure end date is later than the start date";
     $recAction
     Write-Error -ErrorRecord $errorRecord -RecommendedAction $recAction;

     return;
  }
  $timeDiff = New-TimeSpan -Start $userTimes.StartTime -End $userTimes.EndTime;

  Write-Host "`nUser times entered";
  Out-String -InputObject $userTimes -Width 50;
  Write-Host ("This is a time span of {0:00} hours {1:00} minutes" `
               -f $timeDiff.hours, $timeDiff.minutes);

}
#endregion ***** end of function Show-TimeDifference *****

#----------------------------------------------------------

#region ***** function Show-TimeWorked *****
##=============================================
## Function: Show-TimeWorked
## Created: 2013-06-19
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: adds the period of time of worked to the start
##          time given. The start and end times will then
##          be displayed as well as the period of time
##          worked.
##
##          The period of time of worked will be be supplied
##          in the format of 'hours:minutes', ie 05:30.
##
## Returns: N/A
##=============================================
## See also: DateTime Structure
## http://msdn.microsoft.com/en-us/library/system.datetime.aspx
##=============================================
## Note:
## This function relies upon the parameters $StartTime, $AddTime.
##=============================================
function Show-TimeWorked {
[CmdletBinding()]
#[OutputType([System.Collections.Hashtable])]
Param() #end param

  Write-Verbose -Message "This is function Show-TimeWorked";

  New-Variable -Name timeFormat -Value "HH:mm" -Option Constant -Scope Local;
  $culture = New-Object -TypeName System.Globalization.CultureInfo("en-GB");

  $t1 = [DateTime]::ParseExact($StartTime, $timeFormat, $culture);
  $t2 = $t1;

  # Extract the hours and minutes from the parameter and
  # parse to an integer.
  # Hours
  $hh=[Int32]::Parse($AddTime.Substring(0,2));
  # Minutes
  $mm=[Int32]::Parse($AddTime.Substring(3));

  # Create a timespan object with the hours and minutes extracted and
  # add this to variabel 't2' to give us the end time.
  $tSpan = New-TimeSpan -Hours $hh -Minutes $mm;
  $t2 = $t2.Add($tSpan);

  $hash = @{
     StartTime=$t1
     EndTime=$t2;
  }
  $userTimes = New-Object -TypeName PSObject -Property $hash;

  Write-Host ("`nTime worked is {0:00} hours {1:00} minutes" `
               -f $tSpan.hours, $tSpan.minutes);
  Out-String -InputObject $userTimes -Width 50;

}
#endregion ***** end of function Show-TimeWorked *****

#----------------------------------------------------------

#region ***** function Show-RightNow *****
##=============================================
## Function: Show-RightNow
## Created: 2013-06-19
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: displays the start and end times, and the hours
##          worked if you go home at the time the script is
##          run. In other words, the end time is taken to
##          be the time the script is run.
##
## Returns: N/A
##=============================================
## See also: Using the Get-Service Cmdlet
## http://technet.microsoft.com/en-us/library/ee176858.aspx
##=============================================
## Note:
## This function relies upon the parameters $StartTime, $GoHomeNow.
##=============================================
function Show-RightNow {
[CmdletBinding()]
#[OutputType([System.Collections.Hashtable])]
Param() #end param

  Write-Verbose -Message "This is function Show-RightNow";

  New-Variable -Name timeFormat -Value "HH:mm" -Option Constant -Scope Local;
  $culture = New-Object -TypeName System.Globalization.CultureInfo("en-GB");

  $t1 = [DateTime]::ParseExact($StartTime, $timeFormat, $culture);
  $t2 = Get-Date; # Gets the time right now.

  $hash = @{
     StartTime=$t1
     EndTime=$t2;
  }
  $userTimes = New-Object -TypeName PSObject -Property $hash;
  $timeDiff = New-TimeSpan -Start $userTimes.StartTime -End $userTimes.EndTime;

  Write-Host "`nGoing home now";
  Write-Host ("This is a time span of {0:00} hours {1:00} minutes" `
               -f $timeDiff.hours, $timeDiff.minutes);
  Out-String -InputObject $userTimes -Width 50;

}
#endregion ***** end of function Show-RightNow *****

#region ***** function Show-WorkingDay *****
##=============================================
## Function: Show-WorkingDay
## Created: 2013-06-19
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: displays the start and end times for a
##          standard working day with the time
##          added to the start time to obtain the
##          finish time.
##
##          At the time of writing the working day
##          is 7.25 hours.
##
## Returns: N/A
##=============================================
## See also: Using the Get-Service Cmdlet
## http://technet.microsoft.com/en-us/library/ee176858.aspx
##=============================================
## Note:
## This function relies upon the parameters $StartTime, $HomeTime.
##=============================================
function Show-WorkingDay {
[CmdletBinding()]
#[OutputType([System.Collections.Hashtable])]
Param() #end param

  Write-Verbose -Message "This is function Show-WorkingDay";

  New-Variable -Name timeFormat -Value "HH:mm" -Option Constant -Scope Local;
  $culture = New-Object -TypeName System.Globalization.CultureInfo("en-GB");

  $t1 = [DateTime]::ParseExact($StartTime, $timeFormat, $culture);
  $t2 = $t1;

  # This is the standard working day.
  $workingDay = New-TimeSpan -Hours 7 -Minutes 15;
  $t2 = $t2.Add($workingDay);

  $timeDiff = ($t2 - $t1);

  $hash = @{
     StartTime=$t1
     EndTime=$t2;
  }
  $userTimes = New-Object -TypeName PSObject -Property $hash;

  Write-Host ("`nFor a standard working day of {0:00} hours {1:00} minutes" `
               -f $timeDiff.hours, $timeDiff.minutes);
  Write-Host "Your start and end times are:";
  Out-String -InputObject $userTimes -Width 50;
  Write-Host "Excludes lunch times";

}
#endregion ***** end of function Show-WorkingDay *****

#----------------------------------------------------------

#region ***** function main_routine *****
##=============================================
## Function: main_routine
## Created: 2013-06-22
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: main helper function which calls other functions
##          as required by the program logic.
##
## Returns: N/A
##=============================================
function main_routine {
[CmdletBinding()]
#[OutputType([System.Collections.Hashtable])]
Param() #end param

Switch ($PSCmdlet.ParameterSetName)
{
    "Set1" {
          Write-Verbose -Message "Invoking function Show-TimeDifference";
          Show-TimeDifference; break;
    }
    "Set2" {
          Write-Verbose -Message "Invoking function Show-TimeWorked";
          Show-TimeWorked; break;
    }
    "Set3" {
          Write-Verbose -Message "Invoking function Show-RightNow";
          Show-RightNow; break;
    }
    "Set4" {
          Write-Verbose -Message "Invoking function Show-WorkingDay";
          Show-WorkingDay; break;
    }
} #end switch

if ($PSBoundParameters.ContainsKey('StartTime'))
{
   Write-Host "A start time has been entered";
}

if ($PSBoundParameters.ContainsKey('AddTime'))
{
    Write-Host "The elapsed time has been supplied";
    $t1 = [DateTime]::ParseExact($StartTime, $timeFormat, $null);
}

$dd = Get-Date -Format "dddd, dd MMMM yyyy HH:mm"
Write-Output "`nCurrent date/time is: $dd";

#Write-Host $PsCmdlet.ParameterSetName;

}
#endregion ********** end of function main_routine **********

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
   Write-Output 'Calulate work related times';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

if ($PSBoundParameters.ContainsKey('Verbose'))
{
    Write-Verbose -Message "Starting script $($MyInvocation.Mycommand)";

    # Loop through the parameters used.
    foreach ($item in $PSBoundParameters.GetEnumerator())
    {
         Write-Verbose -Message ("Key={0},     Value={1}" -f $item.Key, $item.Value);
    }
}

#Write-Output $PSBoundParameters;

main_routine;
Write-Verbose -Message "All done now!";
##=============================================
## END OF SCRIPT: teatime.ps1
##=============================================
