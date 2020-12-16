<#
.SYNOPSIS

Demonstrate use of a user defined event

.DESCRIPTION

Demonstrate a user defined event via the cmdlet Register-EngineEvent.
When the event is fired, a scriptblock is executed.

.EXAMPLE

./Demo-UserEvent.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Demo-UserEvent.ps1
Author       : Ian Molloy
Last updated : 2020-12-16T18:48:27
Keywords     : func delegate

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
Param() #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

# Demonstrates using "Func<T1,T2,TResult> Delegate" which
# encapsulates a method that has two Int32 parameters
# and returns a value of the type specified by the
# TResult (Boolean) parameter.
$pred = [Func[Int32,Int32,Boolean]]{param($x, $y) $x -eq $y }
Set-Variable -Name 'pred' -Option ReadOnly;

$ActionBlock = {
    <#
    ScriptBlock passed to parameter 'Action' of cmdlet
    Register-EngineEvent.

    $Event is of type:
    TypeName: System.Management.Automation.PSEventArgs

    $EventSubscriber is of type:
    TypeName: System.Management.Automation.PSEventSubscriber
    #>
    $timestamp = ('time is {0}' -f (Get-Date -Format 's'));

    Write-Host '';
    Write-Host "The timestamp is now  - $timestamp";
    Write-Host 'This is from ScriptBlock called ActionBlock';

    # -----
    # Possible useful properties from $Event
    # -----
    Write-Host '';
    Write-Host 'Possible useful properties from $Event';
    Write-Host '';
    #Additional user data associated with this event
    Write-Host "Event.MessageData: $($Event.MessageData)";
    #The object that generated this event
    Write-Host "Event.Sender: $($Event.Sender)";
    #The list of arguments captured by the original event source
    Write-Host "Event.SourceArgs: $($Event.SourceArgs)";
    #The identifier associated with the source of this event
    Write-Host "Event.SourceIdentifier: $($Event.SourceIdentifier)";
    #Time and date that this event was generated
    Write-Host "Event.TimeGenerated: $($Event.TimeGenerated)";

    # -----
    # Possible useful properties from $EventSubscriber
    # -----
    Write-Host '';
    Write-Host 'Possible useful properties from $EventSubscriber';
    Write-Host '';
    #The identifier that identifies the source of these events
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
    Write-Host '';

} #end of scriptblock $ActionBlock
$SourceIdent = "helen";
Set-Variable -Name 'ActionBlock', 'SourceIdent' -Option ReadOnly;

Write-Output 'This is a test ps1 file';

Write-Output 'Trying to register an engine';
$splat = @{
    SourceIdentifier = $SourceIdent;
    Action = $ActionBlock;
}
Register-EngineEvent @splat | Out-Null;
#Get-EventSubscriber;
Write-Output 'Done';

#For the purpose of this demonstration, we're going to use
#the range of numbers 1..10. For this reason, variable
#'$target' will lie within this range.
$target = 4;
Set-Variable -Name 'target' -Option ReadOnly;
Write-Output "The target value is: $target";

foreach ($num in 1..10) {
    Write-Output "num is now: $num";
    if ($pred.Invoke($num, $target)) {
        #Fire up the event now we've reached our target figure
        $msgData = "We've reached our target of $num";
        $splat = @{
            SourceIdentifier = $SourceIdent;
            Sender = "foreach loop";
            EventArguments = "Some arguments that I want to pass";
            MessageData = $msgData;
        }
        New-Event @splat | Out-Null;

    }
} #end of foreach loop

Write-Output 'All done now';
##=============================================
## END OF SCRIPT: Demo-UserEvent.ps1
##=============================================
