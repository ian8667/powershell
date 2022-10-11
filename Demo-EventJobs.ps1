<#
.SYNOPSIS

Demonstrate use of background job event handling

.DESCRIPTION

Event handling. Demonstration file showing how to register
for an event when submitting a background job. When the
event is raised, an action block ScriptBlock informs
us the job has completed. This saves us having to check
upon the status of the job every few minutes.

.EXAMPLE

./Demo-EventJobs.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Demo-EventJobs.ps1
Author       : Ian Molloy
Last updated : 2022-10-11T15:20:27
Keywords     : event handling background job


Event handling automatic variables found in the action
block of cmdlet Register-ObjectEvent parameter 'Action'.

$Event
System.Management.Automation.PSEventArgs Class

Contains a PSEventArgs object that represents the event
that is being processed. This variable is populated only
within the Action block of an event registration command,
such as Register-ObjectEvent. The value of this variable
is the same object that the Get-Event cmdlet returns.
Therefore, you can use the properties of the Event variable,
such as $Event.TimeGenerated, in an Action script block.


$EventArgs
System.Management.Automation.PSEventArgs Class

Contains an object that represents the first event argument
that derives from EventArgs of the event that is being
processed. This variable is populated only within the Action
block of an event registration command. The value of this
variable can also be found in the SourceEventArgs property of
the PSEventArgs object that Get-Event returns.


$EventSubscriber
System.Management.Automation.PSEventSubscriber Class

Contains a PSEventSubscriber object that represents the event
subscriber of the event that is being processed. This variable
is populated only within the Action block of an event
registration command. The value of this variable is the same
object that the Get-EventSubscriber cmdlet returns.


$Sender
System.Management.Automation.PSEventArgs.Sender Property

Contains the object that generated this event. This variable
is populated only within the Action block of an event
registration command. The value of this variable can also
be found in the Sender property of the PSEventArgs object
that Get-Event returns.

Start-ThreadJob - run on a separate thread within the SAME process.
Start-Job - the job is run in the background on a SEPARATE process.

The advantage of ThreadJobs is that they are lighter on
resource consumption because they are using a thread not
a process. You can therefore run more ThreadJobs
simultaneously compared to standard Jobs.

The disadvantage for ThreadJobs is that all of your jobs
are running in the same process. If one crashes the process
will most likely crash and you'll lose everything.

ThreadJobs look to be a useful addition to the options for
running background jobs.

.LINK

Register-EngineEvent
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/register-engineevent?view=powershell-7.1

New-Event
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/new-event?view=powershell-7.1

About Script Blocks
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_script_blocks?view=powershell-7.1

Inspired by the article:
How to implement event handling in PowerShell with classes
https://stackoverflow.com/questions/55527673/how-to-implement-event-handling-in-powershell-with-classes

Event handling
https://stackoverflow.com/questions/55527673/how-to-implement-event-handling-in-powershell-with-classes

PSEventArgs Class
https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.pseventargs?view=powershellsdk-7.0.0
Get-EventSubscriber | Unregister-Event;

About Automatic Variables ($Event, $EventSubscriber, $Sender, $EventArgs, etc)
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.1

Calling a function using Start-Job
https://social.technet.microsoft.com/Forums/windowsserver/en-US/b68c1c68-e0f0-47b7-ba9f-749d06621a2c/calling-a-function-using-startjob

Use Asynchronous Event Handling in PowerShell
https://devblogs.microsoft.com/scripting/use-asynchronous-event-handling-in-powershell/

Func<T1,T2,TResult> Delegate
https://docs.microsoft.com/en-us/dotnet/api/system.func-3?view=netcore-3.1

PSThreadJob
https://github.com/PaulHigin/PSThreadJob

Manage Event Subscriptions with PowerShell
Summary: Bruce Payette shows how to manage event subscriptions
with Windows PowerShell.
https://devblogs.microsoft.com/scripting/manage-event-subscriptions-with-powershell/

#>

[CmdletBinding()]
Param()

#-----------------------------------------------------
# Start of delegates
#-----------------------------------------------------

$Get_Jobname = [Func[System.String]] {
<#
Constructs a job name for us to use for the test. We don't
have to do this but it's a nice way of reminding me how to
construct and use Delegates within a program.
#>
  $num = Get-Random -Minimum 10 -Maximum 500;
  $jobname = ('TestJob{0}' -f $num.ToString());

  #Return the jobname constructed
  $jobname;

} #end Get_Jobname

#-----------------------------------------------------
# End of delegates
#-----------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Demonstration of background jobs and events';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines

#------------------------------------------------

$sb = {
# Do some pretend work.
# ScriptBlock which is passed to parameter 'ScriptBlock' of
# cmdlet Start-ThreadJob or Start-Job in order to do some
# pretend work.
#
# This is effectively the work that gets carried out
# by the background job. Admittedly, the scriptblock
# I'm using here is a trivial example (and doesn't do
# much) but helps to help demonstrate the use of events
# and background jobs.

    $secondsToWait = (60.0 * 2);
    Get-Date -Format 's';
    Get-ChildItem -Path 'C:\Temp' -Directory;
    Start-Sleep -Seconds $secondsToWait
    Write-Host 'scriptblock test complete';
    Get-Date -Format 's';
} #end ScriptBlock sb
Set-Variable -Name 'sb' -Option ReadOnly;

#------------------------------------------------

$ActionBlock = {
# The commands in this scriptblock are run when the event
# is raised (fired).
# This ScriptBlock passed to parameter 'Action' of cmdlet
# Register-ObjectEvent.
#
# The value of the Action parameter can include the
# automatic variables:
#   $Event
#   $EventSubscriber
#   $Sender
#   $EventArgs
#   $Args automatic variables.
# These variables provide information about the event to
# the Action script block.
# See: about_Automatic_Variables
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.2
#
# Properties 'JobStateInfo' and 'PreviousJobStateInfo'
# See:
# System.Management.Automation.JobStateEventArgs Class

    $mystatus = @('Completed', 'Failed');
    $estate = $EventArgs.JobStateInfo.State;

    # Test to see if we managed to pass any data into our scriptblock.
    # We don't do anything with this data.
    Write-Host $Event.MessageData.foo;
    Write-Host $Event.MessageData.bar;

    $ev = $Event;
    $splat = @(
       $ev.Sender.ID
       $ev.Sender.Name
       $ev.SourceEventArgs.PreviousJobStateInfo.State
       $ev.SourceEventArgs.JobStateInfo.State
       );
    Write-Host ("Job Id {0} ({1}) has changed from {2} to {3}" -f $splat);

    if ($estate -in $mystatus) {
        # At this point we know we can clean up as the job
        # status is either 'Completed' or 'Failed'

        Write-Host "Cleaning up unwanted jobs and events";
        $EventSubscriber | Unregister-Event -Force;
        $EventSubscriber.Action | Remove-Job -Force;

        # Be careful of this because if there is information
        # in the job to collect, you will lose it. Collect
        # information from the job first before deleting it
        # if that's what you want to do.
        #$sender | Remove-Job -Force
        Write-Host "Cleanup done";
        Write-Host "";
    }

} #end ScriptBlock ActionBlock
Set-Variable -Name 'ActionBlock' -Option ReadOnly;

#------------------------------------------------

$jobname = $Get_Jobname.Invoke();

# Submit job
# Enables me to submit jobs using either cmdlet 'Start-ThreadJob'
# or 'Start-Job'.
Write-Host ('Submitting background job {0}' -f $jobname);

$ThreadJob = $true;
if ($ThreadJob) {
  # The Start-ThreadJob cmdlet to start the background job
  $cmdletUsed = 'Start-ThreadJob';
  $job = Start-ThreadJob -Name $jobname -ScriptBlock $sb;
} else {
  # The Start-Job cmdlet to start the background job
  $cmdletUsed = 'Start-Job';
  $job = Start-Job -Name $jobname -ScriptBlock $sb;
}
Write-Host "Job submitted using cmdlet $cmdletUsed";

# Create some test data
# This demonstrates how information can be passed to and
# written from the scriptblock which is used as the
# action block.
# We don't do anything with the data, it's just a test.
$ffoo = 'this is my foo';
$bbar = 'this is my bar';
$testdata = New-Object PSObject -Property @{foo = $ffoo; bar = $bbar}


# Register our event of interest
# Because 'InputObject' of this hash table requires
# the input from variable 'job', the job has to be
# submitted already otherwise variable 'job' will
# effectively be null and the event won't be
# submitted and thus we don't get any event notification.
$splat = @{
  InputObject = $job
  EventName = 'StateChanged'
  SourceIdentifier = 'FriendlyName' # Eventjob name (as seend by (Get-Job).Name))
  Action = $ActionBlock # What action to take when the event fires
  MessageData = $testdata # Test data
}
# Returns TypeName: System.Management.Automation.PSEventJob
$reg = Register-ObjectEvent @splat;
#$reg | Format-List -Property *;

##=============================================
## END OF SCRIPT: Demo-EventJobs.ps1
##=============================================
