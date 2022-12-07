<#
.SYNOPSIS

Demonstrate use of a user defined event

.DESCRIPTION

In order to demonstarte a user defined event, an integer number
is entered as a parameter and when a 'foreach' loop reaches that
number, the event is fired (triggered). This is just a simple
demonstartion so the program doesn't do anything else.

.EXAMPLE

./Demo-UserEvent.ps1 -TargetNumber X

Where X is an integer number in the range 1 to 10 inclusive.

.EXAMPLE

./Demo-UserEvent.ps1 X

Where X is an integer number in the range 1 to 10 inclusive.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Demo-UserEvent.ps1
Author       : Ian Molloy
Last updated : 2022-12-07T12:09:19
Keywords     : func delegate user event

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

#>

[CmdletBinding()]
Param(
   [parameter(Position=0,
              Mandatory=$true,
              HelpMessage='Enter integer number (1 - 10) at which to fire a test event')]
   [ValidateRange(1,10)]
   [int]
   $TargetNumber
) #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

#----------------------------------------------------------

$pred = [Func[Int32,Int32,Boolean]]{
<#
There are other ways of doing this but it shows the use of a
delegate in action. 

x - current loop number
y - target number at which we want to fire our event
#>
param($x, $y) $x -eq $y }
Set-Variable -Name 'pred' -Option ReadOnly;

#----------------------------------------------------------

$ActionBlock = {
<#
ScriptBlock passed to parameter 'Action' of cmdlet
Register-EngineEvent. This scriptblock will be
executed when the event is fired.

$Event is of type:
TypeName: System.Management.Automation.PSEventArgs

$EventSubscriber is of type:
TypeName: System.Management.Automation.PSEventSubscriber
#>
    $timestamp = ('time is {0}' -f (Get-Date -Format 's'));

    Write-Host '';
    Write-Host ('=' * 45);
    Write-Host "The timestamp is now  - $timestamp";
    Write-Host 'This is from ScriptBlock called ActionBlock';

    # -----
    # Possible useful properties from $Event
    # -----
    Write-Host '';
    Write-Host 'Possible useful properties from $Event';
    Write-Host '';
    Write-Host "Event.MessageData: $($Event.MessageData)";
    Write-Host "Event.Sender: $($Event.Sender)";
    Write-Host "Event.SourceArgs: $($Event.SourceArgs)";
    Write-Host "Event.SourceIdentifier: $($Event.SourceIdentifier)";
    Write-Host "Event.TimeGenerated: $($Event.TimeGenerated)";

    # -----
    # Possible useful properties from $EventSubscriber
    # -----
    Write-Host '';
    Write-Host 'Possible useful properties from $EventSubscriber';
    Write-Host '';
    Write-Host "EventSubscriber.SourceIdentifier: $($EventSubscriber.SourceIdentifier)";

    # -----
    # Clean up section
    # -----
    Write-Host "Cleaning up unwanted jobs and events";
    #It turns out that the 'SourceIdentifier' is the same as the
    #job name. This means we can remove the job by using the job
    #name.
    $JobName = $Event.SourceIdentifier;
    Write-Host "Trying to stop job name [$JobName]";
    Remove-Job -Force -Name $JobName;
    Write-Host "Cleanup done";
    Write-Host ('=' * 45);
    Write-Host '';

} #end of scriptblock $ActionBlock
Set-Variable -Name 'ActionBlock' -Option ReadOnly;

#----------------------------------------------------------

$SourceIdent = "helen";
Set-Variable -Name 'SourceIdent' -Option ReadOnly;

Write-Output 'Trying to register an engine event';
$splat = @{
    SourceIdentifier = $SourceIdent;
    Action = $ActionBlock;
}
Register-EngineEvent @splat | Out-Null;
#Get-EventSubscriber;
Write-Output 'engine event done';

#For the purpose of this demonstration, we're going to use
#the range of numbers 1..10. For this reason, parameter
#variable '$TargetNumber' will lie within this range.
Write-Output "The target value is: $TargetNumber";

foreach ($num in 1..10) {
    Write-Output "num is now: $num";
    if ($pred.Invoke($num, $TargetNumber)) {
        #Fire up the event now we've reached our target figure
        $msgData = "We've reached our target number of $num. Let's fire an event";
        $splat = @{
            SourceIdentifier = $SourceIdent;
            Sender = "foreach loop";
            EventArguments = "Some arguments that I want to pass";
            MessageData = $msgData;
        }
        New-Event @splat | Out-Null;

    }
} #end of foreach loop
Write-Output 'Test loop complete';

[System.Linq.Enumerable]::Repeat("", 1); #blanklines
Write-Output 'All done now';
##=============================================
## END OF SCRIPT: Demo-UserEvent.ps1
##=============================================
