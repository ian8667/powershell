# temp.ps1
# A temporary scratch file only.
# Creating environment variables suitable for using the PowerShell
# console with Oracle. With this, I can use SQL*Plus within the
# PowerShell console.
#
# Last updated: 25 November 2018 16:07:58
#
[CmdletBinding()]
Param () #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

$params =  @{
    'ORACLE_SID'      = 'ORCL';
    'ORACLE_HOME'     = 'C:\Family\EmailsSent\contents';
    'NLS_DATE_FORMAT' = 'RRRR-MM-DD HH24:MI:SS';
}

$params99 = New-Object PSObject -Property @{
    'ORACLE_SID'      = 'ORCL';
    'ORACLE_HOME'     = 'C:\Test2';
    #'TNS_ADMIN'       = Join-Path -Path $params.Item('ORACLE_HOME') -ChildPath "/NETWORK/ADMIN";
    'NLS_DATE_FORMAT' = 'RRRR-MM-DD HH24:MI:SS';
}

# Check the Oracle Home exists. If not, throw a terminating error.
$dd = $params.ORACLE_HOME;
#$dd = $params.Item('ORACLE_HOME');
if (Test-Path -Path $dd) {
    $key = 'TNS_ADMIN';
    $val = Join-Path -Path $params['ORACLE_HOME'] -ChildPath "/NETWORK/ADMIN";
    $params.Add($key, $val);
} else {
    throw [System.IO.DirectoryNotFoundException] "Oracle Home $dd not found.";
}

$params

$fred = [System.EnvironmentVariableTarget]::Process;
Set-Variable -Name 'fred' -Option ReadOnly;

# Within this loop:
# kvp.Key - the environment variable name.
# kvp.Value - the value assigned to the variable.
foreach ($kvp in $params.GetEnumerator()) {
    [System.Environment]::SetEnvironmentVariable($kvp.Name, $kvp.Value, $fred);
    Write-Verbose -Message ("Environment variable: {0},     {1}" -f $kvp.Name, $kvp.Value);
}

##=============================================
## END OF SCRIPT: temp.ps1
##=============================================
