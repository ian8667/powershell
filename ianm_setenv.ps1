<#
.SYNOPSIS

Create Oracle related environment variables

.DESCRIPTION

Create Oracle related environment variables suitable for using
PowerShell console with Oracle. With this, I can use Oracle
SQL*Plus within the PowerShell console. i.e.,

PS> sqlplus fred@orcl

Without these environment variables, we wouldn't be able to
connect to an Oracle database like this.

.EXAMPLE

./ianm_setenv.ps1

No parameters are required

.EXAMPLE

./ianm_setenv.ps1 -Verbose

Shows the environment variables and values created. No parameters
are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : ianm_setenv.ps1
Author       : Ian Molloy
Last updated : 2019-03-17
Keywords     : oracle environment variable setenv

.LINK

Hashtable Class
Represents a collection of key/value pairs that are organized based on the hash code of the key.
https://msdn.microsoft.com/en-us/library/system.collections.hashtable(v=vs.110).aspx

Approved Verbs for Windows PowerShell Commands
https://msdn.microsoft.com/en-us/library/ms714428(v=vs.85).aspx#Similar Verbs for Different Actions

Get-Verb
The Get-Verb function gets verbs that are approved for use in Windows PowerShell commands.
https://msdn.microsoft.com/en-us/powershell/reference/5.0/microsoft.powershell.core/functions/get-verb

Strongly Encouraged Development Guidelines
https://msdn.microsoft.com/en-us/library/dd878270(v=vs.85).aspx

#>
[CmdletBinding()]
Param () #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

# Allows us to count the number of environment variables
# created.
[Byte]$envCounter = 0;

# Environment variables to create
$params =  @{
  'ORACLE_SID'      = 'ORCL';
  'ORACLE_HOME'     = 'C:\Family\EmailsSent\contents';
  'NLS_DATE_FORMAT' = 'RRRR-MM-DD HH24:MI:SS';
}

# Check 1 - Oracle Home
# Check the Oracle home exists. If so, create environment
# variable TNS_ADMIN which is also based upon the Oracle
# home just validated. If not, throw a terminating error.
$oh = $params.ORACLE_HOME;
#$dd = $params.Item('ORACLE_HOME');
if (Test-Path -Path $oh) {
    $key = 'TNS_ADMIN';
    $val = Join-Path -Path $oh -ChildPath "/NETWORK/ADMIN";
    $params.Add($key, $val);

    Set-Variable -Name 'params' -Option ReadOnly;
} else {
    throw [System.IO.DirectoryNotFoundException] "Oracle Home $oh not found.";
}


# An enumerated type used to specify the environment variable
# created will be stored in the environment block associated
# with the current session only. In other words, these variables
# will not persist across different PowerShell sessions and will
# be deleted when you exit the current PowerShell session.
$proc = [System.EnvironmentVariableTarget]::Process;
Set-Variable -Name 'proc' -Option ReadOnly;


# Check 2 - MS Windows Oracle service
# This test is simply to warn the user if they don't have an
# MS Windows service for the ORACLE_SID environment variable
# just created. For the purpose of this test, it’s assumed
# the service name concerned will be in the format of:
#   "OracleService<ORACLE_SID>".
$sid = [System.Environment]::GetEnvironmentVariable("ORACLE_SID", $proc);
$svc = "OracleService$($sid)";
if (-not (Get-Service -Name $svc -ErrorAction SilentlyContinue)) {
    Write-Output "";
    Write-Warning -Message "Nothing to worry about, but can't find an MS Windows service for ORACLE_SID supplied: $($params.ORACLE_SID)";
    Write-Output "";
}


# Create the environment variables. The following is true
# Within this loop:
#   kvp.Key - the environment variable name.
#   kvp.Value - the value assigned to the variable.
foreach ($kvp in $params.GetEnumerator()) {
    [System.Environment]::SetEnvironmentVariable($kvp.Name, $kvp.Value, $proc);
    Write-Verbose -Message ("Environment variable: {0},     {1}" -f $kvp.Name, $kvp.Value);

    $envCounter++;
}


Write-Output "`nOracle environment variables created: $($envCounter)";
##=============================================
## END OF SCRIPT: ianm_setenv.ps1
##=============================================
