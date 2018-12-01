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
Last updated : 2018-12-01

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

# Environment variables to create
$params =  @{
    'ORACLE_SID'      = 'ORCL';
    'ORACLE_HOME'     = 'C:\Family\EmailsSent\contents';
    'NLS_DATE_FORMAT' = 'RRRR-MM-DD HH24:MI:SS';
}

# Check 1 - Oracle Home
# Check the Oracle Home exists. If so, create environment variable
# TNS_ADMIN else throw a terminating error.
$dd = $params.ORACLE_HOME;
#$dd = $params.Item('ORACLE_HOME');
if (Test-Path -Path $dd) {
    $key = 'TNS_ADMIN';
    $val = Join-Path -Path $params['ORACLE_HOME'] -ChildPath "/NETWORK/ADMIN";
    $params.Add($key, $val);
    Set-Variable -Name 'params' -Option ReadOnly;
} else {
    throw [System.IO.DirectoryNotFoundException] "Oracle Home $dd not found.";
}

# Check 2 - MS Windows Oracle service
# For the purpose of this test, it's assumed the Oracle MS Windows
# service name for instance 'XYZ', for example, will be in the
# format of:
# OracleServiceXYZ.
$svc = "OracleService$($params.ORACLE_SID)";
if (-not (Get-Service -Name $svc -ErrorAction SilentlyContinue)) {
    Write-Warning -Message "Can't find an MS Windows service for ORACLE_SID supplied: $($params.ORACLE_SID)";
    Write-Output "";
}


$fred = [System.EnvironmentVariableTarget]::Process;
Set-Variable -Name 'fred' -Option ReadOnly;

# Within this loop to create the environment variables:
# kvp.Key - the environment variable name.
# kvp.Value - the value assigned to the variable.
foreach ($kvp in $params.GetEnumerator()) {
    [System.Environment]::SetEnvironmentVariable($kvp.Name, $kvp.Value, $fred);
    Write-Verbose -Message ("Environment variable: {0},     {1}" -f $kvp.Name, $kvp.Value);
}

##=============================================
## END OF SCRIPT: ianm_setenv.ps1
##=============================================
