<#
$Event appears to end up as a PSEventArgs Class?
https://msdn.microsoft.com/en-us/library/system.management.automation.pseventargs(v=vs.85).aspx

$Event appears to be:
System.Management.Automation.PSEventArgs

$EventSubscriber appears to be:
System.Management.Automation.PSEventSubscriber

$Sender appears to be:
System.Management.Automation.PSRemotingJob



Last updated: 02 August 2016 19:34:27

#>


# Create a script block.
$sb={
  $secs=7;
  Write-Host 'Hello world';
  
  Start-Sleep -Seconds $secs;
}

[Int16]$num = Get-Random -Minimum 1 -Maximum 250;

Write-Host 'Start of test';

$myjob=Start-Job -Name "testjob$($num.ToString())" -ScriptBlock $sb;
Get-Job;

Register-ObjectEvent -InputObject $myjob -EventName StateChanged `
  -SourceIdentifier 'friendlyName' `
  -Action {
    $kompleted = [System.Management.Automation.JobState]::Completed;

Write-Host ('sourceArgs type = {0}' -f  $sourceArgs.gettype());

    if ($eventargs.JobStateInfo.State -eq $kompleted) {

    #System.Management.Automation.PSEventArgs
    $ev = $Event;
    Write-Host ("Job ID {0} ({1}) has changed from {2} to 
    {3}" -f `
        $ev.Sender.id, `
        $ev.Sender.name, `
        $ev.SourceEventArgs.PreviousJobStateInfo.State, `
        $ev.SourceEventArgs.JobStateInfo.state);

    }

    $eventSubscriber | Unregister-Event -Force;
    $eventSubscriber.Action | Remove-job -Force;

  }
Write-Host 'End of test';





